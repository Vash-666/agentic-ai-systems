"""
Ensemble prediction using Bayesian model averaging.
Weights models by their information coefficient squared.
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
from enum import Enum
import structlog

logger = structlog.get_logger()


class SignalSource(Enum):
    """Sources of predictive signals."""
    WAVELET_REGIME = "wavelet_regime"
    KALMAN_TREND = "kalman_trend"
    KALMAN_VELOCITY = "kalman_velocity"
    MOMENTUM = "momentum"
    MEAN_REVERSION = "mean_reversion"
    CROSS_MARKET = "cross_market"


@dataclass
class ModelPrediction:
    """Individual model prediction."""
    source: SignalSource
    signal: float  # -1 to +1
    confidence: float  # 0 to 1
    expected_return: float  # Predicted return
    variance: float  # Prediction uncertainty
    timestamp: float


@dataclass
class EnsemblePrediction:
    """Final ensemble prediction output."""
    symbol: str
    timestamp: float
    
    # Ensemble results
    ensemble_signal: float  # -1 to +1
    expected_return: float
    variance: float
    confidence: float
    
    # Component breakdown
    model_predictions: List[ModelPrediction] = field(default_factory=list)
    model_weights: Dict[SignalSource, float] = field(default_factory=dict)
    
    # Decision
    recommendation: str = "hold"  # buy, sell, hold
    position_size: float = 0.0  # 0 to 1


class ModelTracker:
    """
    Track model performance for adaptive weighting.
    """
    
    def __init__(self, source: SignalSource, lookback: int = 30):
        """
        Initialize model tracker.
        
        Args:
            source: Signal source type
            lookback: Window for performance calculation
        """
        self.source = source
        self.lookback = lookback
        
        # Performance history
        self.predictions: List[float] = []
        self.actuals: List[float] = []
        self.signals: List[float] = []
        
        # Metrics
        self.information_coefficient = 0.0
        self.sharpe_ratio = 0.0
        self.win_rate = 0.0
        
    def update(self, prediction: float, actual: float, signal: float):
        """Update with new prediction and actual outcome."""
        self.predictions.append(prediction)
        self.actuals.append(actual)
        self.signals.append(signal)
        
        # Keep window
        if len(self.predictions) > self.lookback:
            self.predictions.pop(0)
            self.actuals.pop(0)
            self.signals.pop(0)
            
        # Recalculate metrics
        self._calculate_metrics()
        
    def _calculate_metrics(self):
        """Calculate performance metrics."""
        if len(self.predictions) < 10:
            return
            
        preds = np.array(self.predictions)
        actuals = np.array(self.actuals)
        signals = np.array(self.signals)
        
        # Information coefficient (rank correlation)
        from scipy.stats import spearmanr
        corr, _ = spearmanr(preds, actuals)
        self.information_coefficient = corr if not np.isnan(corr) else 0.0
        
        # Strategy returns (following the signal)
        strategy_returns = signals[:-1] * actuals[1:]  # Signal at t, return at t+1
        
        if len(strategy_returns) > 0 and strategy_returns.std() > 0:
            self.sharpe_ratio = strategy_returns.mean() / strategy_returns.std()
            self.win_rate = (strategy_returns > 0).mean()
        else:
            self.sharpe_ratio = 0.0
            self.win_rate = 0.0
            
    def get_weight(self) -> float:
        """
        Calculate model weight based on performance.
        
        Weight = IC² (information coefficient squared)
        Higher IC = more weight in ensemble
        """
        # Use squared IC, ensure non-negative
        weight = max(0, self.information_coefficient ** 2)
        
        # Boost by Sharpe if positive
        if self.sharpe_ratio > 0:
            weight *= (1 + self.sharpe_ratio)
            
        return weight


class EnsemblePredictor:
    """
    Bayesian model averaging ensemble predictor.
    
    Combines multiple signal sources, weighted by their
    historical information coefficient.
    """
    
    def __init__(
        self,
        symbol: str,
        sources: List[SignalSource] = None,
        min_weight_threshold: float = 0.01
    ):
        """
        Initialize ensemble predictor.
        
        Args:
            symbol: Asset symbol
            sources: List of signal sources to use
            min_weight_threshold: Minimum weight for inclusion
        """
        self.symbol = symbol
        self.sources = sources or list(SignalSource)
        self.min_weight_threshold = min_weight_threshold
        
        # Trackers for each model
        self.trackers = {
            source: ModelTracker(source)
            for source in self.sources
        }
        
        # Current weights
        self.weights: Dict[SignalSource, float] = {}
        
        # History for variance estimation
        self.prediction_history: List[Tuple[float, float]] = []  # (pred, actual)
        
    def add_prediction(
        self,
        source: SignalSource,
        signal: float,
        confidence: float,
        expected_return: float,
        variance: float,
        timestamp: float
    ) -> ModelPrediction:
        """
        Add a prediction from a model.
        
        Args:
            source: Signal source
            signal: Direction signal (-1 to +1)
            confidence: Model confidence (0 to 1)
            expected_return: Predicted return
            variance: Prediction variance
            timestamp: Timestamp
            
        Returns:
            ModelPrediction object
        """
        pred = ModelPrediction(
            source=source,
            signal=signal,
            confidence=confidence,
            expected_return=expected_return,
            variance=variance,
            timestamp=timestamp
        )
        
        return pred
        
    def calculate_ensemble(
        self,
        predictions: List[ModelPrediction],
        timestamp: float
    ) -> EnsemblePrediction:
        """
        Calculate ensemble prediction from component models.
        
        Args:
            predictions: List of model predictions
            timestamp: Current timestamp
            
        Returns:
            EnsemblePrediction with weighted average
        """
        if not predictions:
            return EnsemblePrediction(
                symbol=self.symbol,
                timestamp=timestamp,
                ensemble_signal=0.0,
                expected_return=0.0,
                variance=1.0,
                confidence=0.0,
                recommendation="hold",
                position_size=0.0
            )
            
        # Get weights for each model
        weights = {}
        for pred in predictions:
            tracker = self.trackers[pred.source]
            weights[pred.source] = tracker.get_weight()
            
        # Normalize weights
        total_weight = sum(weights.values())
        if total_weight > 0:
            weights = {k: v / total_weight for k, v in weights.items()}
        else:
            # Equal weights if no history
            weights = {pred.source: 1.0 / len(predictions) for pred in predictions}
            
        # Filter by threshold
        weights = {
            k: v for k, v in weights.items()
            if v >= self.min_weight_threshold
        }
        
        # Renormalize after filtering
        total_weight = sum(weights.values())
        if total_weight > 0:
            weights = {k: v / total_weight for k, v in weights.items()}
            
        self.weights = weights
        
        # Calculate weighted ensemble
        weighted_signal = 0.0
        weighted_return = 0.0
        weighted_variance = 0.0
        total_confidence = 0.0
        
        for pred in predictions:
            if pred.source in weights:
                w = weights[pred.source]
                weighted_signal += w * pred.signal * pred.confidence
                weighted_return += w * pred.expected_return
                weighted_variance += (w ** 2) * pred.variance
                total_confidence += w * pred.confidence
                
        # Calculate ensemble confidence
        # Based on: weight concentration, model agreement, historical accuracy
        weight_entropy = -sum(w * np.log(w) for w in weights.values() if w > 0)
        max_entropy = np.log(len(weights)) if len(weights) > 1 else 1
        weight_concentration = 1 - (weight_entropy / max_entropy if max_entropy > 0 else 0)
        
        # Model agreement (variance of signals)
        signals = [p.signal for p in predictions if p.source in weights]
        signal_variance = np.var(signals) if len(signals) > 1 else 0
        agreement = 1 - min(signal_variance * 2, 1)
        
        ensemble_confidence = weight_concentration * agreement * total_confidence
        
        # Generate recommendation
        recommendation, position_size = self._generate_recommendation(
            weighted_signal, ensemble_confidence, weighted_variance
        )
        
        return EnsemblePrediction(
            symbol=self.symbol,
            timestamp=timestamp,
            ensemble_signal=weighted_signal,
            expected_return=weighted_return,
            variance=weighted_variance,
            confidence=ensemble_confidence,
            model_predictions=predictions,
            model_weights=weights,
            recommendation=recommendation,
            position_size=position_size
        )
        
    def _generate_recommendation(
        self,
        signal: float,
        confidence: float,
        variance: float
    ) -> Tuple[str, float]:
        """
        Generate trading recommendation from ensemble signal.
        
        Args:
            signal: Ensemble signal (-1 to +1)
            confidence: Ensemble confidence (0 to 1)
            variance: Prediction variance
            
        Returns:
            (recommendation, position_size)
        """
        # Thresholds
        signal_threshold = 0.2
        confidence_threshold = 0.3
        
        # Require both signal strength and confidence
        if abs(signal) < signal_threshold or confidence < confidence_threshold:
            return "hold", 0.0
            
        # Position sizing based on confidence and inverse variance
        base_size = abs(signal)
        confidence_adjustment = confidence
        variance_adjustment = 1 / (1 + variance * 10)
        
        position_size = base_size * confidence_adjustment * variance_adjustment
        position_size = min(position_size, 1.0)  # Cap at 100%
        
        if signal > 0:
            return "buy", position_size
        else:
            return "sell", position_size
            
    def update_performance(
        self,
        predictions: List[ModelPrediction],
        actual_return: float
    ):
        """
        Update model trackers with actual outcomes.
        
        Args:
            predictions: Predictions that were made
            actual_return: Actual return that occurred
        """
        for pred in predictions:
            tracker = self.trackers[pred.source]
            tracker.update(
                prediction=pred.expected_return,
                actual=actual_return,
                signal=pred.signal
            )
            
        # Track ensemble performance
        self.prediction_history.append((
            sum(p.expected_return * self.weights.get(p.source, 0) for p in predictions),
            actual_return
        ))
        
        if len(self.prediction_history) > 100:
            self.prediction_history.pop(0)
            
    def get_ensemble_ic(self) -> float:
        """Calculate information coefficient of ensemble."""
        if len(self.prediction_history) < 10:
            return 0.0
            
        preds, actuals = zip(*self.prediction_history)
        
        from scipy.stats import spearmanr
        corr, _ = spearmanr(preds, actuals)
        
        return corr if not np.isnan(corr) else 0.0


class MultiAssetEnsemble:
    """
    Manage ensemble predictors for multiple assets.
    """
    
    def __init__(self, symbols: List[str]):
        """
        Initialize multi-asset ensemble.
        
        Args:
            symbols: List of asset symbols
        """
        self.symbols = symbols
        self.predictors = {
            symbol: EnsemblePredictor(symbol)
            for symbol in symbols
        }
        
    def get_predictor(self, symbol: str) -> Optional[EnsemblePredictor]:
        """Get predictor for a symbol."""
        return self.predictors.get(symbol)
        
    def get_all_predictions(self) -> Dict[str, EnsemblePrediction]:
        """Get current predictions for all assets."""
        # This would be called after each predictor has been updated
        # For now, return empty dict - actual usage would store latest
        return {}
        
    def get_best_opportunity(self) -> Optional[Tuple[str, EnsemblePrediction]]:
        """
        Identify best trading opportunity across all assets.
        
        Returns:
            (symbol, prediction) with highest expected risk-adjusted return
        """
        best = None
        best_score = -np.inf
        
        for symbol, predictor in self.predictors.items():
            # Would need to store latest prediction
            # For now, placeholder
            pass
            
        return best


# Example usage
if __name__ == "__main__":
    # Create ensemble predictor
    predictor = EnsemblePredictor("AAPL")
    
    # Simulate predictions from different models
    predictions = [
        ModelPrediction(
            source=SignalSource.WAVELET_REGIME,
            signal=0.6,
            confidence=0.7,
            expected_return=0.02,
            variance=0.001,
            timestamp=1.0
        ),
        ModelPrediction(
            source=SignalSource.KALMAN_TREND,
            signal=0.4,
            confidence=0.8,
            expected_return=0.015,
            variance=0.0008,
            timestamp=1.0
        ),
        ModelPrediction(
            source=SignalSource.MOMENTUM,
            signal=-0.3,
            confidence=0.5,
            expected_return=-0.01,
            variance=0.002,
            timestamp=1.0
        )
    ]
    
    # Calculate ensemble
    ensemble = predictor.calculate_ensemble(predictions, timestamp=1.0)
    
    print(f"Symbol: {ensemble.symbol}")
    print(f"Ensemble Signal: {ensemble.ensemble_signal:+.3f}")
    print(f"Expected Return: {ensemble.expected_return:+.3f}")
    print(f"Variance: {ensemble.variance:.6f}")
    print(f"Confidence: {ensemble.confidence:.3f}")
    print(f"Recommendation: {ensemble.recommendation.upper()}")
    print(f"Position Size: {ensemble.position_size:.1%}")
    print("\nModel Weights:")
    for source, weight in ensemble.model_weights.items():
        print(f"  {source.value}: {weight:.3f}")
