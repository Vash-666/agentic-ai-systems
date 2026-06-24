"""
Refined signal power calculation with normalized components and risk adjustment.
"""

import numpy as np
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple
from scipy.stats import entropy as scipy_entropy, spearmanr
from scipy.signal import welch
import structlog

logger = structlog.get_logger()

# Constants for normalization
MAX_MI = 2.0           # Theoretical max mutual information (bits)
MAX_ENTROPY = 6.0      # log2(50 bins) for discretized data
RISK_AVERSION = 2.0    # Lambda for risk penalty


@dataclass
class RefinedSignalPowerMetrics:
    """Refined signal power metrics with normalized components."""
    symbol: str
    timestamp: float
    
    # Raw components
    mutual_information: float
    shannon_entropy: float
    spectral_entropy: float
    volatility: float
    
    # Normalized components [0,1]
    mi_normalized: float
    entropy_normalized: float
    spectral_concentration: float
    risk_adjustment: float
    
    # Refined signal power
    signal_power: float  # [0,1]
    confidence: float    # [0,1]
    
    # Information coefficient (time-decayed)
    information_coefficient: float
    ic_decayed: float


class RefinedSignalPowerCalculator:
    """
    Refined signal power calculator with:
    - Normalized components [0,1]
    - Risk adjustment
    - Time-decayed IC
    - Spectral concentration (not raw energy)
    """
    
    def __init__(
        self,
        lookback: int = 100,
        ic_decay_halflife: int = 30,
        max_mi: float = MAX_MI,
        max_entropy: float = MAX_ENTROPY,
        risk_aversion: float = RISK_AVERSION
    ):
        """
        Initialize refined calculator.
        
        Args:
            lookback: Window for calculations
            ic_decay_halflife: Days for IC to decay by half
            max_mi: Maximum mutual information for normalization
            max_entropy: Maximum entropy for normalization
            risk_aversion: Lambda for risk penalty
        """
        self.lookback = lookback
        self.ic_decay_halflife = ic_decay_halflife
        self.max_mi = max_mi
        self.max_entropy = max_entropy
        self.risk_aversion = risk_aversion
        
        # History for time-decayed IC
        self.prediction_history: List[Tuple[float, float, float]] = []
        # (timestamp, prediction, actual)
        
    def calculate_mutual_information(
        self,
        x: np.ndarray,
        y: np.ndarray,
        bins: int = 20
    ) -> float:
        """Calculate normalized mutual information."""
        if len(x) != len(y) or len(x) < 10:
            return 0.0
            
        # 2D histogram
        joint_hist, _, _ = np.histogram2d(x, y, bins=bins)
        joint_prob = joint_hist / joint_hist.sum()
        
        # Marginals
        x_prob = joint_prob.sum(axis=1)
        y_prob = joint_prob.sum(axis=0)
        
        # MI calculation
        mi = 0.0
        for i in range(bins):
            for j in range(bins):
                if joint_prob[i, j] > 0 and x_prob[i] > 0 and y_prob[j] > 0:
                    mi += joint_prob[i, j] * np.log2(
                        joint_prob[i, j] / (x_prob[i] * y_prob[j])
                    )
                    
        return max(0.0, mi)
        
    def calculate_spectral_concentration(
        self,
        returns: np.ndarray,
        nperseg: int = None
    ) -> float:
        """
        Calculate spectral concentration (not raw energy).
        
        Concentration = 1 - normalized spectral entropy
        High concentration = strong periodic component
        """
        if len(returns) < 8:
            return 0.5
            
        if nperseg is None:
            nperseg = min(256, len(returns) // 4)
            
        # Power spectral density
        f, psd = welch(returns, fs=1.0, nperseg=nperseg)
        
        if psd.sum() == 0:
            return 0.5
            
        # Normalize to probability distribution
        psd_norm = psd / psd.sum()
        
        # Spectral entropy
        psd_positive = psd_norm[psd_norm > 0]
        spectral_entropy = -np.sum(psd_positive * np.log2(psd_positive))
        
        # Normalize by max entropy (uniform distribution)
        max_spectral_entropy = np.log2(len(psd))
        
        # Concentration = 1 - normalized entropy
        concentration = 1 - (spectral_entropy / max_spectral_entropy if max_spectral_entropy > 0 else 0)
        
        return float(concentration)
        
    def calculate_shannon_entropy(
        self,
        data: np.ndarray,
        bins: int = 50
    ) -> float:
        """Calculate Shannon entropy."""
        if len(data) < 2:
            return self.max_entropy
            
        hist, _ = np.histogram(data, bins=bins, density=True)
        hist = hist[hist > 0]
        
        if len(hist) == 0:
            return self.max_entropy
            
        return scipy_entropy(hist)
        
    def calculate_volatility(self, returns: np.ndarray) -> float:
        """Calculate annualized volatility."""
        if len(returns) < 2:
            return 0.0
            
        # Annualized (assuming daily returns)
        return float(np.std(returns) * np.sqrt(252))
        
    def calculate_ic_time_decayed(self, current_time: float) -> float:
        """
        Calculate time-decayed information coefficient.
        
        Recent predictions weighted more heavily.
        """
        if len(self.prediction_history) < 10:
            return 0.0
            
        # Extract predictions and actuals with time weights
        predictions = []
        actuals = []
        weights = []
        
        for timestamp, pred, actual in self.prediction_history:
            # Exponential decay
            age = current_time - timestamp
            decay = 0.5 ** (age / self.ic_decay_halflife)
            
            predictions.append(pred)
            actuals.append(actual)
            weights.append(decay)
            
        predictions = np.array(predictions)
        actuals = np.array(actuals)
        weights = np.array(weights)
        
        # Weighted Spearman correlation
        # Simplified: use ranks with weights
        pred_ranks = np.argsort(np.argsort(predictions))
        actual_ranks = np.argsort(np.argsort(actuals))
        
        # Weighted correlation
        weighted_mean_pred = np.average(pred_ranks, weights=weights)
        weighted_mean_actual = np.average(actual_ranks, weights=weights)
        
        numerator = np.sum(
            weights * (pred_ranks - weighted_mean_pred) * 
            (actual_ranks - weighted_mean_actual)
        )
        
        denominator = np.sqrt(
            np.sum(weights * (pred_ranks - weighted_mean_pred)**2) *
            np.sum(weights * (actual_ranks - weighted_mean_actual)**2)
        )
        
        if denominator == 0:
            return 0.0
            
        ic = numerator / denominator
        return ic if not np.isnan(ic) else 0.0
        
    def calculate(
        self,
        symbol: str,
        prices: np.ndarray,
        timestamp: float = None
    ) -> RefinedSignalPowerMetrics:
        """
        Calculate refined signal power.
        
        SP = MI_norm × (1 - H_norm)² × √SE_conc × (1 + λσ²)^(-1)
        """
        if timestamp is None:
            timestamp = float(len(prices))
            
        # Ensure sufficient data
        if len(prices) < self.lookback:
            prices = np.pad(prices, (self.lookback - len(prices), 0), mode='edge')
        else:
            prices = prices[-self.lookback:]
            
        # Calculate returns
        returns = np.diff(prices) / prices[:-1]
        
        # 1. Raw components
        # Mutual information with lagged self
        if len(returns) >= 21:
            mi = self.calculate_mutual_information(returns[:-1], returns[1:])
        else:
            mi = 0.0
            
        shannon_entropy = self.calculate_shannon_entropy(returns)
        spectral_conc = self.calculate_spectral_concentration(returns)
        volatility = self.calculate_volatility(returns)
        
        # 2. Normalized components [0,1]
        mi_norm = min(mi / self.max_mi, 1.0)
        entropy_norm = min(shannon_entropy / self.max_entropy, 1.0)
        # spectral_conc already in [0,1]
        
        # Risk adjustment: penalize high volatility
        risk_adj = 1.0 / (1.0 + self.risk_aversion * (volatility ** 2))
        
        # 3. Refined signal power
        # SP = MI_norm × (1 - H_norm)² × √SE_conc × risk_adj
        signal_power = (
            mi_norm *
            ((1 - entropy_norm) ** 2) *
            (spectral_conc ** 0.5) *
            risk_adj
        )
        
        # 4. Time-decayed IC
        ic_decayed = self.calculate_ic_time_decayed(timestamp)
        
        # 5. Confidence
        # Based on signal power and IC consistency
        prediction_consistency = abs(ic_decayed) if not np.isnan(ic_decayed) else 0.0
        confidence = signal_power * (0.5 + 0.5 * prediction_consistency)
        
        return RefinedSignalPowerMetrics(
            symbol=symbol,
            timestamp=timestamp,
            mutual_information=mi,
            shannon_entropy=shannon_entropy,
            spectral_entropy=1 - spectral_conc,  # Convert back for storage
            volatility=volatility,
            mi_normalized=mi_norm,
            entropy_normalized=entropy_norm,
            spectral_concentration=spectral_conc,
            risk_adjustment=risk_adj,
            signal_power=signal_power,
            confidence=confidence,
            information_coefficient=ic_decayed,
            ic_decayed=ic_decayed
        )
        
    def update_performance(
        self,
        prediction: float,
        actual: float,
        timestamp: float
    ):
        """Update with new prediction and actual for IC calculation."""
        self.prediction_history.append((timestamp, prediction, actual))
        
        # Keep window
        max_history = self.lookback * 2
        if len(self.prediction_history) > max_history:
            self.prediction_history.pop(0)


class RefinedCrossMarketAnalyzer:
    """
    Cross-market analysis with refined signal power.
    """
    
    def __init__(self, symbols: List[str], **kwargs):
        self.symbols = symbols
        self.calculators = {
            symbol: RefinedSignalPowerCalculator(**kwargs)
            for symbol in symbols
        }
        self.returns_history = {sym: [] for sym in symbols}
        
    def update_market(
        self,
        symbol: str,
        price: float,
        timestamp: float = None
    ) -> Optional[RefinedSignalPowerMetrics]:
        """Update market with new price."""
        if symbol not in self.calculators:
            return None
            
        # Store return
        if len(self.returns_history[symbol]) > 0:
            last_price = self.returns_history[symbol][-1]
            ret = (price - last_price) / last_price if last_price != 0 else 0
        else:
            ret = 0.0
            
        self.returns_history[symbol].append(price)  # Store price, not return
        
        # Keep window
        max_window = 200
        if len(self.returns_history[symbol]) > max_window:
            self.returns_history[symbol].pop(0)
            
        # Calculate if sufficient data
        if len(self.returns_history[symbol]) >= 50:
            prices = np.array(self.returns_history[symbol])
            return self.calculators[symbol].calculate(symbol, prices, timestamp)
            
        return None


# Example usage
if __name__ == "__main__":
    np.random.seed(42)
    
    # Test data: trending (predictable)
    trend = np.linspace(100, 120, 100) + np.random.randn(100) * 0.3
    
    # Test data: random (unpredictable)
    random_walk = 110 + np.cumsum(np.random.randn(100) * 0.5)
    
    calc = RefinedSignalPowerCalculator()
    
    for name, prices in [("trend", trend), ("random", random_walk)]:
        metrics = calc.calculate(name, prices)
        print(f"\n{name.upper()}:")
        print(f"  Signal Power: {metrics.signal_power:.3f}")
        print(f"  MI (norm): {metrics.mi_normalized:.3f}")
        print(f"  Entropy (norm): {metrics.entropy_normalized:.3f}")
        print(f"  Spectral Conc: {metrics.spectral_concentration:.3f}")
        print(f"  Risk Adj: {metrics.risk_adjustment:.3f}")
        print(f"  Confidence: {metrics.confidence:.3f}")
