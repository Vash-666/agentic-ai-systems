"""
Refined ensemble predictor with softmax weighting, diversity bonus, and covariance adjustment.
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
from enum import Enum
import structlog

logger = structlog.get_logger()

# Constants
TEMPERATURE = 3.0              # Tau for softmax
MIN_CONFIDENCE = 0.3           # Minimum confidence for inclusion
CORRELATION_CAP = 0.5          # Max correlation for adjustment


class SignalSource(Enum):
    """Sources of predictive signals."""
    WAVELET_REGIME = "wavelet_regime"
    KALMAN_TREND = "kalman_trend"
    KALMAN_VELOCITY = "kalman_velocity"
    MOMENTUM = "momentum"
    MEAN_REVERSION = "mean_reversion"
    CROSS_MARKET = "cross_market"


@dataclass
class RefinedModelPrediction:
    """Model prediction with confidence and IC."""
    source: SignalSource
    forecast: float           # Predicted return
    signal: float            # Direction signal (-1 to +1)
    confidence: float        # Model confidence [0,1]
    ic: float               # Information coefficient
    variance: float         # Prediction variance
    timestamp: float


@dataclass
class RefinedEnsemblePrediction:
    """Final refined ensemble output."""
    symbol: str
    timestamp: float
    
    # Ensemble results
    ensemble_forecast: float
    ensemble_signal: float
    variance: float
    confidence: float
    
    # Components
    model_predictions: List[RefinedModelPrediction] = field(default_factory=list)
    model_weights: Dict[SignalSource, float] = field(default_factory=dict)
    diversity_bonus: float = 0.0
    avg_correlation: float = 0.0
    
    # Decision
    recommendation: str = "hold"
    position_size: float = 0.0
    confidence_interval_95: Tuple[float, float] = (0.0, 0.0)


class RefinedModelTracker:
    """Track model performance with time decay."""
    
    def __init__(self, source: SignalSource, lookback: int = 30):
        self.source = source
        self.lookback = lookback
        
        # Performance history: (timestamp, prediction, actual, signal)
        self.history: List[Tuple[float, float, float, float]] = []
        
        # Current metrics
        self.ic = 0.0
        self.ic_decayed = 0.0
        self.sharpe = 0.0
        self.win_rate = 0.0
        
    def update(self, timestamp: float, prediction: float, actual: float, signal: float):
        """Update with new performance data."""
        self.history.append((timestamp, prediction, actual, signal))
        
        # Keep window
        if len(self.history) > self.lookback:
            self.history.pop(0)
            
        self._calculate_metrics(timestamp)
        
    def _calculate_metrics(self, current_time: float):
        """Calculate time-decayed metrics."""
        if len(self.history) < 10:
            return
            
        # Time decay weights
        halflife = 20  # days
        timestamps, preds, actuals, signals = zip(*self.history)
        
        ages = np.array([current_time - t for t in timestamps])
        weights = 0.5 ** (ages / halflife)
        weights = weights / weights.sum()  # Normalize
        
        preds = np.array(preds)
        actuals = np.array(actuals)
        signals = np.array(signals)
        
        # Weighted IC (Spearman)
        try:
            from scipy.stats import spearmanr
            # Use recent data for IC
            recent_mask = ages < 30
            if recent_mask.sum() >= 10:
                self.ic, _ = spearmanr(
                    preds[recent_mask],
                    actuals[recent_mask]
                )
            else:
                self.ic = 0.0
        except:
            self.ic = 0.0
            
        # Time-decayed IC (simplified)
        self.ic_decayed = self.ic * 0.8  # Decay factor
        
        # Strategy returns
        strategy_returns = signals[:-1] * actuals[1:]
        if len(strategy_returns) > 0:
            weighted_returns = np.average(strategy_returns, weights=weights[1:])
            weighted_std = np.sqrt(np.average(
                (strategy_returns - weighted_returns) ** 2,
                weights=weights[1:]
            ))
            
            self.sharpe = weighted_returns / weighted_std if weighted_std > 0 else 0.0
            self.win_rate = np.average(strategy_returns > 0, weights=weights[1:])


class RefinedEnsemblePredictor:
    """
    Refined ensemble with:
    - Softmax weighting: w_i ∝ exp(τ × IC_i × C_i × (1 + D_i))
    - Diversity bonus for uncorrelated models
    - Covariance-adjusted variance
    """
    
    def __init__(
        self,
        symbol: str,
        sources: List[SignalSource] = None,
        temperature: float = TEMPERATURE,
        min_confidence: float = MIN_CONFIDENCE
    ):
        self.symbol = symbol
        self.sources = sources or list(SignalSource)
        self.temperature = temperature
        self.min_confidence = min_confidence
        
        # Model trackers
        self.trackers = {
            source: RefinedModelTracker(source)
            for source in self.sources
        }
        
        # Prediction history for correlation calculation
        self.prediction_history: Dict[SignalSource, List[float]] = {
            source: [] for source in self.sources
        }
        
        self.weights: Dict[SignalSource, float] = {}
        
    def add_prediction(
        self,
        source: SignalSource,
        forecast: float,
        signal: float,
        confidence: float,
        ic: float,
        variance: float,
        timestamp: float
    ) -> RefinedModelPrediction:
        """Create model prediction."""
        return RefinedModelPrediction(
            source=source,
            forecast=forecast,
            signal=signal,
            confidence=confidence,
            ic=ic,
            variance=variance,
            timestamp=timestamp
        )
        
    def calculate_diversity_bonus(
        self,
        predictions: List[RefinedModelPrediction]
    ) -> Tuple[Dict[SignalSource, float], float, float]:
        """
        Calculate diversity bonus for each model.
        
        Models that make uncorrelated predictions get bonus.
        
        Returns:
            (diversity_bonus_dict, avg_correlation, max_correlation)
        """
        if len(predictions) < 2:
            return {p.source: 1.0 for p in predictions}, 0.0, 0.0
            
        # Update prediction history
        for pred in predictions:
            self.prediction_history[pred.source].append(pred.forecast)
            if len(self.prediction_history[pred.source]) > 50:
                self.prediction_history[pred.source].pop(0)
                
        # Calculate pairwise correlations
        sources = [p.source for p in predictions]
        n = len(sources)
        correlations = []
        
        for i, source_i in enumerate(sources):
            # Average correlation of model i with all others
            corrs = []
            for j, source_j in enumerate(sources):
                if i != j:
                    hist_i = self.prediction_history[source_i]
                    hist_j = self.prediction_history[source_j]
                    
                    if len(hist_i) >= 10 and len(hist_j) >= 10:
                        min_len = min(len(hist_i), len(hist_j))
                        corr = np.corrcoef(hist_i[-min_len:], hist_j[-min_len:])[0, 1]
                        if not np.isnan(corr):
                            corrs.append(abs(corr))
                            
            avg_corr = np.mean(corrs) if corrs else 0.5
            correlations.append(avg_corr)
            
        # Diversity bonus: lower correlation = higher bonus
        # D_i = 1 / (1 + ρ̄_i)
        diversity_bonuses = {
            source: 1.0 / (1.0 + min(corr, CORRELATION_CAP))
            for source, corr in zip(sources, correlations)
        }
        
        avg_correlation = np.mean(correlations) if correlations else 0.0
        max_correlation = np.max(correlations) if correlations else 0.0
        
        return diversity_bonuses, avg_correlation, max_correlation
        
    def calculate_weights(
        self,
        predictions: List[RefinedModelPrediction],
        diversity_bonuses: Dict[SignalSource, float]
    ) -> Dict[SignalSource, float]:
        """
        Calculate softmax weights.
        
        w_i = exp[τ × IC_i × C_i × (1 + D_i)] / Σ_j exp[...]
        """
        if not predictions:
            return {}
            
        # Calculate scores
        scores = {}
        for pred in predictions:
            if pred.confidence < self.min_confidence:
                scores[pred.source] = 0.0
            else:
                # Use IC magnitude but preserve sign via forecast
                ic_score = abs(pred.ic) * np.sign(pred.forecast) if pred.forecast != 0 else 0
                diversity = diversity_bonuses.get(pred.source, 1.0)
                
                # Score = IC × Confidence × Diversity
                score = ic_score * pred.confidence * diversity
                scores[pred.source] = score
                
        # Softmax
        exp_scores = {
            k: np.exp(self.temperature * s) if s > 0 else 0
            for k, s in scores.items()
        }
        
        total = sum(exp_scores.values())
        if total > 0:
            weights = {k: v / total for k, v in exp_scores.items()}
        else:
            # Equal weights if all scores are 0
            weights = {k: 1.0 / len(predictions) for k in scores.keys()}
            
        return weights
        
    def calculate_ensemble(
        self,
        predictions: List[RefinedModelPrediction],
        timestamp: float
    ) -> RefinedEnsemblePrediction:
        """Calculate refined ensemble prediction."""
        if not predictions:
            return RefinedEnsemblePrediction(
                symbol=self.symbol,
                timestamp=timestamp,
                ensemble_forecast=0.0,
                ensemble_signal=0.0,
                variance=1.0,
                confidence=0.0,
                recommendation="hold",
                position_size=0.0
            )
            
        # Calculate diversity bonuses
        diversity_bonuses, avg_corr, max_corr = self.calculate_diversity_bonus(predictions)
        
        # Calculate weights
        weights = self.calculate_weights(predictions, diversity_bonuses)
        self.weights = weights
        
        # Ensemble forecast (weighted average)
        ensemble_forecast = sum(
            weights.get(p.source, 0) * p.forecast
            for p in predictions
        )
        
        # Ensemble signal (weighted average of signals)
        ensemble_signal = sum(
            weights.get(p.source, 0) * p.signal * p.confidence
            for p in predictions
        )
        
        # Variance components
        # Within-model variance
        variance_within = sum(
            (weights.get(p.source, 0) ** 2) * p.variance
            for p in predictions
        )
        
        # Between-model variance (disagreement)
        variance_between = sum(
            weights.get(p.source, 0) * (p.forecast - ensemble_forecast) ** 2
            for p in predictions
        )
        
        # Covariance adjustment
        k = len(predictions)
        covariance_adj = 1 + min(avg_corr, CORRELATION_CAP) * (k - 1)
        
        total_variance = (variance_within + variance_between) * covariance_adj
        
        # Confidence
        weight_entropy = -sum(
            w * np.log(w) for w in weights.values() if w > 0
        )
        max_entropy = np.log(len(weights)) if len(weights) > 1 else 1
        weight_concentration = 1 - (weight_entropy / max_entropy if max_entropy > 0 else 0)
        
        # Model agreement
        signals = [p.signal for p in predictions]
        signal_variance = np.var(signals) if len(signals) > 1 else 0
        agreement = 1 - min(signal_variance * 2, 1)
        
        confidence = weight_concentration * agreement * np.mean([p.confidence for p in predictions])
        
        # Confidence interval
        std = np.sqrt(total_variance)
        ci_lower = ensemble_forecast - 1.96 * std
        ci_upper = ensemble_forecast + 1.96 * std
        
        # Recommendation
        recommendation, position_size = self._generate_recommendation(
            ensemble_signal, confidence, total_variance
        )
        
        return RefinedEnsemblePrediction(
            symbol=self.symbol,
            timestamp=timestamp,
            ensemble_forecast=ensemble_forecast,
            ensemble_signal=ensemble_signal,
            variance=total_variance,
            confidence=confidence,
            model_predictions=predictions,
            model_weights=weights,
            diversity_bonus=np.mean(list(diversity_bonuses.values())),
            avg_correlation=avg_corr,
            recommendation=recommendation,
            position_size=position_size,
            confidence_interval_95=(ci_lower, ci_upper)
        )
        
    def _generate_recommendation(
        self,
        signal: float,
        confidence: float,
        variance: float
    ) -> Tuple[str, float]:
        """Generate trading recommendation."""
        signal_threshold = 0.2
        confidence_threshold = 0.3
        
        if abs(signal) < signal_threshold or confidence < confidence_threshold:
            return "hold", 0.0
            
        base_size = abs(signal)
        confidence_adj = confidence
        variance_adj = 1 / (1 + variance * 100)
        
        position_size = min(base_size * confidence_adj * variance_adj, 1.0)
        
        return "buy" if signal > 0 else "sell", position_size
        
    def update_performance(
        self,
        predictions: List[RefinedModelPrediction],
        actual_return: float,
        timestamp: float
    ):
        """Update model trackers."""
        for pred in predictions:
            tracker = self.trackers[pred.source]
            tracker.update(
                timestamp=timestamp,
                prediction=pred.forecast,
                actual=actual_return,
                signal=pred.signal
            )


# Example usage
if __name__ == "__main__":
    predictor = RefinedEnsemblePredictor("AAPL", temperature=3.0)
    
    # Simulate predictions
    predictions = [
        RefinedModelPrediction(
            source=SignalSource.WAVELET_REGIME,
            forecast=0.02,
            signal=0.6,
            confidence=0.7,
            ic=0.15,
            variance=0.001,
            timestamp=1.0
        ),
        RefinedModelPrediction(
            source=SignalSource.KALMAN_TREND,
            forecast=0.015,
            signal=0.5,
            confidence=0.8,
            ic=0.12,
            variance=0.0008,
            timestamp=1.0
        ),
        RefinedModelPrediction(
            source=SignalSource.MOMENTUM,
            forecast=-0.01,
            signal=-0.4,
            confidence=0.5,
            ic=0.08,
            variance=0.002,
            timestamp=1.0
        )
    ]
    
    ensemble = predictor.calculate_ensemble(predictions, timestamp=1.0)
    
    print(f"Symbol: {ensemble.symbol}")
    print(f"Forecast: {ensemble.ensemble_forecast:+.3f}")
    print(f"Signal: {ensemble.ensemble_signal:+.3f}")
    print(f"Variance: {ensemble.variance:.6f}")
    print(f"Confidence: {ensemble.confidence:.3f}")
    print(f"Diversity Bonus: {ensemble.diversity_bonus:.3f}")
    print(f"Avg Correlation: {ensemble.avg_correlation:.3f}")
    print(f"95% CI: [{ensemble.confidence_interval_95[0]:+.3f}, {ensemble.confidence_interval_95[1]:+.3f}]")
    print(f"Recommendation: {ensemble.recommendation.upper()}")
    print(f"Position Size: {ensemble.position_size:.1%}")
    print("\nModel Weights:")
    for source, weight in ensemble.model_weights.items():
        print(f"  {source.value}: {weight:.3f}")
