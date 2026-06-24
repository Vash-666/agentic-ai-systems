"""
Wavelet decomposition for market regime detection.
Identifies trending, ranging, and volatile periods.
"""

import numpy as np
import pywt
from dataclasses import dataclass
from enum import Enum
from typing import List, Tuple, Optional
import structlog

logger = structlog.get_logger()


class MarketRegime(Enum):
    """Market regime classifications."""
    TRENDING_UP = "trending_up"
    TRENDING_DOWN = "trending_down"
    RANGING = "ranging"
    VOLATILE = "volatile"
    UNKNOWN = "unknown"


@dataclass
class WaveletFeatures:
    """Features extracted from wavelet decomposition."""
    symbol: str
    timestamp: float
    regime: MarketRegime
    trend_strength: float
    volatility: float
    dominant_scale: int
    energy_distribution: np.ndarray
    detail_coeffs: List[np.ndarray]
    approximation: np.ndarray


class WaveletAnalyzer:
    """
    Wavelet-based market regime detector.
    
    Uses discrete wavelet transform to decompose price into
    different frequency bands, then classifies regime based
    on energy distribution across scales.
    """
    
    def __init__(
        self,
        wavelet: str = "db4",
        levels: int = 5,
        lookback: int = 128
    ):
        """
        Initialize wavelet analyzer.
        
        Args:
            wavelet: Wavelet family (db4 = Daubechies 4)
            levels: Decomposition levels (scales)
            lookback: Number of data points to analyze
        """
        self.wavelet = wavelet
        self.levels = levels
        self.lookback = lookback
        
        # Validate wavelet
        if wavelet not in pywt.wavelist():
            raise ValueError(f"Unknown wavelet: {wavelet}")
            
    def decompose(self, prices: np.ndarray) -> Tuple[List[np.ndarray], np.ndarray]:
        """
        Perform wavelet decomposition.
        
        Returns:
            (detail_coeffs, approximation)
            detail_coeffs: List of detail coefficients at each level
            approximation: Approximation coefficients (lowest frequency)
        """
        # Ensure sufficient data
        if len(prices) < self.lookback:
            logger.warning(
                "Insufficient data for decomposition",
                have=len(prices),
                need=self.lookback
            )
            # Pad with last value
            prices = np.pad(
                prices,
                (self.lookback - len(prices), 0),
                mode='edge'
            )
        else:
            prices = prices[-self.lookback:]
            
        # Perform multilevel decomposition
        coeffs = pywt.wavedec(prices, self.wavelet, level=self.levels)
        
        # coeffs[0] = approximation (lowest frequency trend)
        # coeffs[1:] = detail coefficients (high frequency components)
        approximation = coeffs[0]
        detail_coeffs = coeffs[1:]
        
        return detail_coeffs, approximation
        
    def calculate_energy(self, detail_coeffs: List[np.ndarray]) -> np.ndarray:
        """
        Calculate energy at each decomposition level.
        
        Energy = sum of squared coefficients
        Higher energy = stronger signal at that frequency
        """
        energies = np.array([
            np.sum(np.square(c)) for c in detail_coeffs
        ])
        
        # Normalize to probability distribution
        if energies.sum() > 0:
            energies = energies / energies.sum()
            
        return energies
        
    def detect_regime(
        self,
        prices: np.ndarray,
        detail_coeffs: List[np.ndarray],
        approximation: np.ndarray
    ) -> MarketRegime:
        """
        Detect market regime from wavelet decomposition.
        
        Logic:
        - High energy in low frequencies (high levels) = trending
        - High energy in mid frequencies = ranging
        - High energy in high frequencies (level 1) = volatile
        """
        energies = self.calculate_energy(detail_coeffs)
        
        # Calculate trend direction from approximation
        trend_slope = np.polyfit(range(len(approximation)), approximation, 1)[0]
        
        # Energy ratios
        low_freq_energy = energies[-2:].sum() if len(energies) >= 2 else 0  # Levels 4-5
        mid_freq_energy = energies[1:3].sum() if len(energies) >= 3 else 0   # Levels 2-3
        high_freq_energy = energies[0] if len(energies) >= 1 else 0          # Level 1
        
        # Regime classification
        if high_freq_energy > 0.4:
            return MarketRegime.VOLATILE
        elif low_freq_energy > 0.5:
            if trend_slope > 0:
                return MarketRegime.TRENDING_UP
            else:
                return MarketRegime.TRENDING_DOWN
        elif mid_freq_energy > 0.4:
            return MarketRegime.RANGING
        else:
            return MarketRegime.UNKNOWN
            
    def calculate_trend_strength(
        self,
        approximation: np.ndarray,
        detail_coeffs: List[np.ndarray]
    ) -> float:
        """
        Calculate trend strength (0-1 scale).
        
        Based on ratio of low-frequency energy to total energy.
        """
        total_variation = np.sum([np.var(c) for c in detail_coeffs])
        trend_variation = np.var(approximation)
        
        if total_variation + trend_variation == 0:
            return 0.0
            
        strength = trend_variation / (trend_variation + total_variation)
        return float(strength)
        
    def calculate_volatility(
        self,
        detail_coeffs: List[np.ndarray]
    ) -> float:
        """
        Calculate volatility from high-frequency components.
        """
        if not detail_coeffs:
            return 0.0
            
        # High frequency = first detail coefficient
        high_freq = detail_coeffs[0]
        return float(np.std(high_freq))
        
    def analyze(self, symbol: str, prices: np.ndarray, timestamp: float = None) -> WaveletFeatures:
        """
        Perform full wavelet analysis on price series.
        
        Args:
            symbol: Asset symbol
            prices: Array of price values
            timestamp: Current timestamp
            
        Returns:
            WaveletFeatures with regime and metrics
        """
        if timestamp is None:
            timestamp = float(len(prices))
            
        # Decompose
        detail_coeffs, approximation = self.decompose(prices)
        
        # Extract features
        regime = self.detect_regime(prices, detail_coeffs, approximation)
        trend_strength = self.calculate_trend_strength(approximation, detail_coeffs)
        volatility = self.calculate_volatility(detail_coeffs)
        energy_distribution = self.calculate_energy(detail_coeffs)
        dominant_scale = int(np.argmax(energy_distribution))
        
        return WaveletFeatures(
            symbol=symbol,
            timestamp=timestamp,
            regime=regime,
            trend_strength=trend_strength,
            volatility=volatility,
            dominant_scale=dominant_scale,
            energy_distribution=energy_distribution,
            detail_coeffs=detail_coeffs,
            approximation=approximation
        )
        
    def get_regime_signal(self, features: WaveletFeatures) -> float:
        """
        Convert regime to numeric signal (-1 to +1).
        
        Returns:
            -1.0 = strong downtrend
            -0.5 = weak downtrend
             0.0 = ranging
            +0.5 = weak uptrend
            +1.0 = strong uptrend
        """
        regime_signals = {
            MarketRegime.TRENDING_DOWN: -1.0,
            MarketRegime.TRENDING_UP: 1.0,
            MarketRegime.RANGING: 0.0,
            MarketRegime.VOLATILE: 0.0,  # Neutral in high volatility
            MarketRegime.UNKNOWN: 0.0
        }
        
        base_signal = regime_signals.get(features.regime, 0.0)
        
        # Modulate by trend strength
        return base_signal * features.trend_strength


class MultiScaleAnalyzer:
    """
    Analyze market across multiple time scales simultaneously.
    """
    
    def __init__(
        self,
        scales: List[int] = None,
        wavelet: str = "db4"
    ):
        """
        Initialize multi-scale analyzer.
        
        Args:
            scales: List of lookback periods (e.g., [32, 64, 128])
            wavelet: Wavelet family
        """
        self.scales = scales or [32, 64, 128]
        self.analyzers = {
            scale: WaveletAnalyzer(wavelet=wavelet, lookback=scale)
            for scale in self.scales
        }
        
    def analyze_all_scales(
        self,
        symbol: str,
        prices: np.ndarray,
        timestamp: float = None
    ) -> Dict[int, WaveletFeatures]:
        """
        Analyze market at all configured scales.
        
        Returns:
            Dict mapping scale to WaveletFeatures
        """
        results = {}
        for scale, analyzer in self.analyzers.items():
            if len(prices) >= scale:
                results[scale] = analyzer.analyze(symbol, prices, timestamp)
            else:
                logger.warning(
                    "Insufficient data for scale",
                    scale=scale,
                    have=len(prices)
                )
        return results
        
    def get_consensus_signal(
        self,
        scale_results: Dict[int, WaveletFeatures]
    ) -> Tuple[float, float]:
        """
        Get consensus signal across all scales.
        
        Returns:
            (consensus_signal, confidence)
            consensus_signal: -1 to +1
            confidence: 0 to 1 (agreement across scales)
        """
        if not scale_results:
            return 0.0, 0.0
            
        signals = []
        for scale, features in scale_results.items():
            analyzer = self.analyzers[scale]
            signal = analyzer.get_regime_signal(features)
            signals.append(signal)
            
        signals = np.array(signals)
        consensus = np.mean(signals)
        
        # Confidence = 1 - normalized variance
        variance = np.var(signals)
        confidence = max(0, 1 - variance * 4)  # Scale so variance=0.25 → confidence=0
        
        return float(consensus), float(confidence)


# Example usage
if __name__ == "__main__":
    # Generate synthetic price data
    np.random.seed(42)
    
    # Trending period
    trend = np.linspace(100, 120, 128) + np.random.randn(128) * 0.5
    
    # Ranging period
    ranging = 110 + np.sin(np.linspace(0, 8*np.pi, 128)) * 5 + np.random.randn(128) * 0.3
    
    # Volatile period
    volatile = 110 + np.random.randn(128) * 3
    
    analyzer = WaveletAnalyzer(wavelet="db4", levels=5, lookback=128)
    
    for name, prices in [("trend", trend), ("range", ranging), ("volatile", volatile)]:
        features = analyzer.analyze(name, prices)
        signal = analyzer.get_regime_signal(features)
        print(f"\n{name.upper()}:")
        print(f"  Regime: {features.regime.value}")
        print(f"  Trend Strength: {features.trend_strength:.3f}")
        print(f"  Volatility: {features.volatility:.3f}")
        print(f"  Signal: {signal:+.3f}")
        print(f"  Energy Distribution: {features.energy_distribution.round(3)}")
