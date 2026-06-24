"""
Main entry point for Signal Power Prediction System.
Orchestrates data ingestion, transformation, analysis, and prediction.
"""

import asyncio
import os
import signal
import sys
from datetime import datetime
from typing import Dict, List

import numpy as np
import structlog

from src.ingestion.websocket_feed import (
    MarketTick, MultiMarketFeed, PolygonWebSocket, AlpacaWebSocket
)
from src.transform.wavelet_decomp import MultiScaleAnalyzer
from src.transform.kalman_filter import MultiSymbolKalmanTracker
from src.analysis.signal_power import CrossMarketAnalyzer
from src.prediction.ensemble import (
    EnsemblePredictor, ModelPrediction, SignalSource
)

# Configure logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


class SignalPowerSystem:
    """
    Main system orchestrating all components.
    """
    
    def __init__(self):
        """Initialize the system."""
        logger.info("Initializing Signal Power Prediction System")
        
        # Load configuration
        self.symbols = self._load_symbols()
        logger.info("Loaded symbols", symbols=self.symbols)
        
        # Initialize components
        self.price_history: Dict[str, List[float]] = {
            sym: [] for sym in self.symbols
        }
        self.tick_buffer: Dict[str, List[MarketTick]] = {
            sym: [] for sym in self.symbols
        }
        
        # Transform components
        self.wavelet_analyzer = MultiScaleAnalyzer(
            scales=[32, 64, 128],
            wavelet="db4"
        )
        self.kalman_tracker = MultiSymbolKalmanTracker(
            self.symbols,
            process_noise=0.01,
            measurement_noise=1.0
        )
        
        # Analysis components
        self.signal_analyzer = CrossMarketAnalyzer(self.symbols)
        
        # Prediction components
        self.predictors: Dict[str, EnsemblePredictor] = {
            sym: EnsemblePredictor(sym) for sym in self.symbols
        }
        
        # Data feed
        self.feed = MultiMarketFeed()
        
        # Running state
        self.running = False
        
    def _load_symbols(self) -> List[str]:
        """Load symbols from environment."""
        stocks = os.getenv("STOCKS", "AAPL,MSFT,GOOGL").split(",")
        forex = os.getenv("FOREX", "").split(",") if os.getenv("FOREX") else []
        crypto = os.getenv("CRYPTO", "").split(",") if os.getenv("CRYPTO") else []
        
        all_symbols = stocks + forex + crypto
        return [s.strip() for s in all_symbols if s.strip()]
        
    def _on_tick(self, tick: MarketTick):
        """Handle incoming market tick."""
        # Buffer tick
        self.tick_buffer[tick.symbol].append(tick)
        
        # Keep last 1000 ticks
        if len(self.tick_buffer[tick.symbol]) > 1000:
            self.tick_buffer[tick.symbol].pop(0)
            
        # Update price history (use closing/mid price)
        price = tick.price
        self.price_history[tick.symbol].append(price)
        
        # Keep last 200 prices
        if len(self.price_history[tick.symbol]) > 200:
            self.price_history[tick.symbol].pop(0)
            
        # Update Kalman filter
        self.kalman_tracker.update(tick.symbol, price, tick.timestamp.timestamp())
        
        # Process if sufficient data
        if len(self.price_history[tick.symbol]) >= 50:
            self._process_symbol(tick.symbol)
            
    def _process_symbol(self, symbol: str):
        """Process a symbol's data through the pipeline."""
        prices = np.array(self.price_history[symbol])
        timestamp = float(len(prices))
        
        try:
            # 1. Wavelet Analysis
            wavelet_results = self.wavelet_analyzer.analyze_all_scales(
                symbol, prices, timestamp
            )
            wavelet_signal, wavelet_conf = self.wavelet_analyzer.get_consensus_signal(
                wavelet_results
            )
            
            # 2. Kalman Analysis
            kalman_state = self.kalman_tracker.get_state(symbol)
            kalman_signal = self.kalman_tracker.get_signal(symbol)
            
            # 3. Signal Power Calculation
            signal_metrics = self.signal_analyzer.update_market(
                symbol, prices[-1], timestamp
            )
            
            # 4. Build predictions for ensemble
            predictions = []
            
            # Wavelet prediction
            if wavelet_results:
                latest_scale = max(wavelet_results.keys())
                features = wavelet_results[latest_scale]
                predictions.append(ModelPrediction(
                    source=SignalSource.WAVELET_REGIME,
                    signal=wavelet_signal,
                    confidence=wavelet_conf,
                    expected_return=wavelet_signal * features.volatility * 0.1,
                    variance=features.volatility ** 2,
                    timestamp=timestamp
                ))
                
            # Kalman predictions
            if kalman_state:
                predictions.append(ModelPrediction(
                    source=SignalSource.KALMAN_TREND,
                    signal=kalman_signal,
                    confidence=self.kalman_tracker.filters[symbol].get_trend_confidence(),
                    expected_return=kalman_state.velocity_estimate * 0.1,
                    variance=kalman_state.uncertainty / 10000,
                    timestamp=timestamp
                ))
                
                predictions.append(ModelPrediction(
                    source=SignalSource.KALMAN_VELOCITY,
                    signal=np.sign(kalman_state.velocity_estimate),
                    confidence=min(abs(kalman_state.velocity_estimate) / 0.5, 1.0),
                    expected_return=kalman_state.velocity_estimate * 0.05,
                    variance=kalman_state.uncertainty / 10000,
                    timestamp=timestamp
                ))
                
            # Signal power prediction
            if signal_metrics:
                predictions.append(ModelPrediction(
                    source=SignalSource.MOMENTUM,
                    signal=np.sign(signal_metrics.information_coefficient),
                    confidence=signal_metrics.overall_power,
                    expected_return=signal_metrics.information_coefficient * 0.02,
                    variance=signal_metrics.variance,
                    timestamp=timestamp
                ))
                
            # 5. Ensemble prediction
            if predictions:
                ensemble = self.predictors[symbol].calculate_ensemble(
                    predictions, timestamp
                )
                
                # Log significant signals
                if abs(ensemble.ensemble_signal) > 0.3 and ensemble.confidence > 0.4:
                    logger.info(
                        "Trading signal detected",
                        symbol=symbol,
                        signal=f"{ensemble.ensemble_signal:+.3f}",
                        confidence=f"{ensemble.confidence:.2f}",
                        recommendation=ensemble.recommendation,
                        position_size=f"{ensemble.position_size:.1%}",
                        expected_return=f"{ensemble.expected_return:+.3f}"
                    )
                    
                    # Print to console for visibility
                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] {symbol}")
                    print(f"  Signal: {ensemble.ensemble_signal:+.3f}")
                    print(f"  Confidence: {ensemble.confidence:.1%}")
                    print(f"  Action: {ensemble.recommendation.upper()}")
                    print(f"  Size: {ensemble.position_size:.1%}")
                    
        except Exception as e:
            logger.error("Error processing symbol", symbol=symbol, error=str(e))
            
    async def start(self):
        """Start the system."""
        logger.info("Starting Signal Power Prediction System")
        self.running = True
        
        # Setup data feed
        try:
            if os.getenv("POLYGON_API_KEY"):
                feed = PolygonWebSocket(self.symbols, self._on_tick)
                self.feed.add_feed(feed)
                logger.info("Added Polygon feed")
            elif os.getenv("ALPACA_API_KEY"):
                feed = AlpacaWebSocket(self.symbols, self._on_tick)
                self.feed.add_feed(feed)
                logger.info("Added Alpaca feed")
            else:
                logger.error("No API key configured")
                return
                
        except Exception as e:
            logger.error("Failed to setup feed", error=str(e))
            return
            
        # Handle shutdown gracefully
        def signal_handler(sig, frame):
            logger.info("Shutdown signal received")
            self.running = False
            
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        
        # Start feed
        try:
            await self.feed.start()
        except Exception as e:
            logger.error("Feed error", error=str(e))
        finally:
            await self.feed.stop()
            logger.info("System stopped")
            
    def get_status(self) -> Dict:
        """Get current system status."""
        return {
            "running": self.running,
            "symbols": self.symbols,
            "data_points": {
                sym: len(self.price_history[sym])
                for sym in self.symbols
            },
            "ensemble_ics": {
                sym: self.predictors[sym].get_ensemble_ic()
                for sym in self.symbols
            }
        }


async def main():
    """Main entry point."""
    print("=" * 60)
    print("Signal Power Prediction System")
    print("Real-time multi-market signal processing")
    print("=" * 60)
    print()
    
    # Check environment
    if not os.getenv("POLYGON_API_KEY") and not os.getenv("ALPACA_API_KEY"):
        print("ERROR: No API key configured")
        print("Set POLYGON_API_KEY or ALPACA_API_KEY in .env file")
        sys.exit(1)
        
    # Create and start system
    system = SignalPowerSystem()
    
    try:
        await system.start()
    except KeyboardInterrupt:
        print("\nShutting down...")
        

if __name__ == "__main__":
    asyncio.run(main())
