"""
Signal power calculation using information theory and physics principles.
"""

import numpy as np
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
from scipy.stats import entropy as scipy_entropy
from scipy.signal import welch
import structlog

logger = structlog.get_logger()


@dataclass
class SignalPowerMetrics:
    """Comprehensive signal power metrics."""
    symbol: str
    timestamp: float
    
    # Information theory metrics
    shannon_entropy: float
    mutual_information: float
    information_coefficient: float
    
    # Spectral metrics
    spectral_energy: float
    dominant_frequency: float
    frequency_entropy: float
    
    # Signal-to-noise
    snr_db: float
    signal_power: float
    noise_power: float
    
    # Combined score
    overall_power: float
    confidence: float


class InformationCalculator:
    """
    Calculate information-theoretic metrics for market signals.
    """
    
    @staticmethod
    def shannon_entropy(data: np.ndarray, bins: int = 50) -> float:
        """
        Calculate Shannon entropy of price distribution.
        
        Lower entropy = more predictable (less uncertainty)
        Higher entropy = more random (more uncertainty)
        """
        if len(data) < 2:
            return 0.0
            
        # Discretize into bins
        hist, _ = np.histogram(data, bins=bins, density=True)
        
        # Remove zeros
        hist = hist[hist > 0]
        
        if len(hist) == 0:
            return 0.0
            
        return scipy_entropy(hist)
        
    @staticmethod
    def mutual_information(
        x: np.ndarray,
        y: np.ndarray,
        bins: int = 20
    ) -> float:
        """
        Calculate mutual information between two signals.
        
        I(X;Y) = H(X) + H(Y) - H(X,Y)
        
        Higher MI = more predictive power
        """
        if len(x) != len(y) or len(x) < 10:
            return 0.0
            
        # 2D histogram for joint distribution
        joint_hist, _, _ = np.histogram2d(x, y, bins=bins)
        joint_prob = joint_hist / joint_hist.sum()
        
        # Marginal distributions
        x_prob = joint_prob.sum(axis=1)
        y_prob = joint_prob.sum(axis=0)
        
        # Calculate MI
        mi = 0.0
        for i in range(bins):
            for j in range(bins):
                if joint_prob[i, j] > 0 and x_prob[i] > 0 and y_prob[j] > 0:
                    mi += joint_prob[i, j] * np.log2(
                        joint_prob[i, j] / (x_prob[i] * y_prob[j])
                    )
                    
        return max(0.0, mi)
        
    @staticmethod
    def information_coefficient(
        predictions: np.ndarray,
        actuals: np.ndarray
    ) -> float:
        """
        Calculate Information Coefficient (IC).
        
        IC = correlation(predicted_returns, actual_returns)
        
        Standard metric in quantitative finance for signal quality.
        """
        if len(predictions) != len(actuals) or len(predictions) < 10:
            return 0.0
            
        # Rank correlation (Spearman) is more robust
        from scipy.stats import spearmanr
        
        corr, pvalue = spearmanr(predictions, actuals)
        
        if np.isnan(corr):
            return 0.0
            
        return float(corr)


class SpectralAnalyzer:
    """
    Spectral analysis for signal power in frequency domain.
    """
    
    @staticmethod
    def power_spectral_density(
        data: np.ndarray,
        fs: float = 1.0,
        nperseg: int = None
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Calculate power spectral density using Welch's method.
        
        Returns:
            (frequencies, power_spectral_density)
        """
        if len(data) < 8:
            return np.array([]), np.array([])
            
        if nperseg is None:
            nperseg = min(256, len(data) // 4)
            
        f, psd = welch(data, fs=fs, nperseg=nperseg)
        
        return f, psd
        
    @staticmethod
    def spectral_energy(psd: np.ndarray) -> float:
        """Total energy in spectrum."""
        return float(np.sum(psd))
        
    @staticmethod
    def dominant_frequency(f: np.ndarray, psd: np.ndarray) -> float:
        """Frequency with maximum power."""
        if len(psd) == 0:
            return 0.0
        max_idx = np.argmax(psd)
        return float(f[max_idx])
        
    @staticmethod
    def spectral_entropy(psd: np.ndarray) -> float:
        """
        Entropy of power spectral density.
        
        Uniform spectrum = high entropy (noise-like)
        Concentrated spectrum = low entropy (periodic signal)
        """
        if len(psd) == 0 or psd.sum() == 0:
            return 0.0
            
        # Normalize to probability distribution
        psd_norm = psd / psd.sum()
        
        return scipy_entropy(psd_norm)


class SignalPowerCalculator:
    """
    Main calculator for signal power metrics.
    
    Combines information theory, spectral analysis, and
    signal-to-noise calculations into unified power score.
    """
    
    def __init__(
        self,
        lookback: int = 100,
        mi_lookback: int = 20
    ):
        """
        Initialize calculator.
        
        Args:
            lookback: Window for main calculations
            mi_lookback: Window for mutual information (shorter for responsiveness)
        """
        self.lookback = lookback
        self.mi_lookback = mi_lookback
        
        self.info_calc = InformationCalculator()
        self.spec_analyzer = SpectralAnalyzer()
        
        # History for IC calculation
        self.prediction_history: List[float] = []
        self.actual_history: List[float] = []
        
    def calculate_snr(
        self,
        prices: np.ndarray,
        trend: np.ndarray = None
    ) -> Tuple[float, float, float]:
        """
        Calculate signal-to-noise ratio.
        
        Args:
            prices: Price series
            trend: Estimated trend (if None, use moving average)
            
        Returns:
            (snr_db, signal_power, noise_power)
        """
        if len(prices) < 10:
            return 0.0, 0.0, 0.0
            
        if trend is None:
            # Use moving average as trend estimate
            window = min(20, len(prices) // 4)
            trend = np.convolve(prices, np.ones(window)/window, mode='same')
            
        # Signal = trend
        signal = trend
        
        # Noise = deviation from trend
        noise = prices - trend
        
        # Calculate powers
        signal_power = np.mean(signal ** 2)
        noise_power = np.var(noise)
        
        if noise_power == 0:
            snr_db = 100.0  # Infinite SNR
        else:
            snr_db = 10 * np.log10(signal_power / noise_power)
            
        return float(snr_db), float(signal_power), float(noise_power)
        
    def calculate(
        self,
        symbol: str,
        prices: np.ndarray,
        returns: np.ndarray = None,
        predictions: np.ndarray = None,
        timestamp: float = None
    ) -> SignalPowerMetrics:
        """
        Calculate full signal power metrics.
        
        Args:
            symbol: Asset symbol
            prices: Price series
            returns: Return series (optional)
            predictions: Predicted returns for IC (optional)
            timestamp: Current timestamp
            
        Returns:
            SignalPowerMetrics with all calculations
        """
        if timestamp is None:
            timestamp = float(len(prices))
            
        # Ensure sufficient data
        if len(prices) < self.lookback:
            prices = np.pad(prices, (self.lookback - len(prices), 0), mode='edge')
        else:
            prices = prices[-self.lookback:]
            
        # Calculate returns if not provided
        if returns is None:
            returns = np.diff(prices) / prices[:-1]
            
        # 1. Information theory metrics
        shannon_entropy = self.info_calc.shannon_entropy(returns)
        
        # Mutual information with lagged self (autocorrelation info)
        if len(returns) >= self.mi_lookback + 1:
            mi = self.info_calc.mutual_information(
                returns[:-1],
                returns[1:]
            )
        else:
            mi = 0.0
            
        # Information coefficient
        if predictions is not None and len(predictions) == len(returns):
            ic = self.info_calc.information_coefficient(predictions, returns)
        else:
            ic = 0.0
            
        # 2. Spectral metrics
        f, psd = self.spec_analyzer.power_spectral_density(returns)
        spectral_energy = self.spec_analyzer.spectral_energy(psd)
        dominant_freq = self.spec_analyzer.dominant_frequency(f, psd)
        freq_entropy = self.spec_analyzer.spectral_entropy(psd)
        
        # 3. Signal-to-noise
        snr_db, sig_power, noise_power = self.calculate_snr(prices)
        
        # 4. Combined signal power score
        # Normalize components to 0-1 scale
        
        # Entropy: lower is better (more predictable), so invert
        entropy_score = 1.0 / (1.0 + shannon_entropy)
        
        # MI: higher is better
        mi_score = min(mi / 2.0, 1.0)  # Normalize, cap at 1
        
        # IC: absolute value, higher is better
        ic_score = abs(ic)
        
        # Spectral energy: higher concentration = more signal
        spectral_score = 1.0 - freq_entropy / np.log(len(psd) + 1)
        
        # SNR: convert dB to linear, normalize
        snr_linear = 10 ** (snr_db / 10)
        snr_score = min(snr_linear / 100.0, 1.0)
        
        # Weighted combination (tune these weights based on backtests)
        overall_power = (
            0.20 * entropy_score +
            0.25 * mi_score +
            0.20 * ic_score +
            0.15 * spectral_score +
            0.20 * snr_score
        )
        
        # Confidence based on data quality
        confidence = min(len(prices) / self.lookback, 1.0) * (0.5 + 0.5 * ic_score)
        
        return SignalPowerMetrics(
            symbol=symbol,
            timestamp=timestamp,
            shannon_entropy=float(shannon_entropy),
            mutual_information=float(mi),
            information_coefficient=float(ic),
            spectral_energy=float(spectral_energy),
            dominant_frequency=float(dominant_freq),
            frequency_entropy=float(freq_entropy),
            snr_db=float(snr_db),
            signal_power=float(sig_power),
            noise_power=float(noise_power),
            overall_power=float(overall_power),
            confidence=float(confidence)
        )
        
    def update_predictions(
        self,
        prediction: float,
        actual: float
    ):
        """Update history for IC calculation."""
        self.prediction_history.append(prediction)
        self.actual_history.append(actual)
        
        # Keep fixed window
        if len(self.prediction_history) > self.lookback:
            self.prediction_history.pop(0)
            self.actual_history.pop(0)
            
    def get_ic_history(self) -> float:
        """Get IC over recent history."""
        if len(self.prediction_history) < 10:
            return 0.0
            
        return self.info_calc.information_coefficient(
            np.array(self.prediction_history),
            np.array(self.actual_history)
        )


class CrossMarketAnalyzer:
    """
    Analyze signal power across multiple markets.
    Identifies predictive relationships between assets.
    """
    
    def __init__(self, symbols: List[str]):
        """
        Initialize cross-market analyzer.
        
        Args:
            symbols: List of market symbols to analyze
        """
        self.symbols = symbols
        self.calculators = {
            symbol: SignalPowerCalculator()
            for symbol in symbols
        }
        
        # Store recent returns for cross-market MI
        self.returns_history: Dict[str, List[float]] = {
            symbol: [] for symbol in symbols
        }
        
    def update_market(
        self,
        symbol: str,
        price: float,
        timestamp: float = None
    ) -> Optional[SignalPowerMetrics]:
        """
        Update a market with new price data.
        
        Returns:
            SignalPowerMetrics if sufficient data
        """
        if symbol not in self.calculators:
            return None
            
        # Store return
        if len(self.returns_history[symbol]) > 0:
            last_price = self.returns_history[symbol][-1] if isinstance(self.returns_history[symbol][-1], float) else price
            ret = (price - last_price) / last_price if last_price != 0 else 0
        else:
            ret = 0.0
            
        self.returns_history[symbol].append(ret)
        
        # Keep window
        max_window = 200
        if len(self.returns_history[symbol]) > max_window:
            self.returns_history[symbol].pop(0)
            
        # Calculate if sufficient data
        if len(self.returns_history[symbol]) >= 50:
            prices = np.array(self.returns_history[symbol])
            return self.calculators[symbol].calculate(
                symbol, prices, timestamp=timestamp
            )
            
        return None
        
    def get_cross_market_mi(self) -> Dict[Tuple[str, str], float]:
        """
        Calculate mutual information between all market pairs.
        
        Returns:
            Dict mapping (symbol1, symbol2) to MI score
        """
        mi_matrix = {}
        
        for i, sym1 in enumerate(self.symbols):
            for sym2 in self.symbols[i+1:]:
                returns1 = np.array(self.returns_history[sym1])
                returns2 = np.array(self.returns_history[sym2])
                
                if len(returns1) >= 20 and len(returns2) >= 20:
                    # Use common length
                    min_len = min(len(returns1), len(returns2))
                    mi = InformationCalculator.mutual_information(
                        returns1[-min_len:],
                        returns2[-min_len:]
                    )
                    mi_matrix[(sym1, sym2)] = mi
                    
        return mi_matrix
        
    def get_leading_market(self) -> Optional[str]:
        """
        Identify which market has highest predictive power for others.
        
        Returns:
            Symbol with highest average mutual information to others
        """
        mi_matrix = self.get_cross_market_mi()
        
        if not mi_matrix:
            return None
            
        # Calculate average MI for each symbol
        avg_mi = {sym: 0.0 for sym in self.symbols}
        counts = {sym: 0 for sym in self.symbols}
        
        for (sym1, sym2), mi in mi_matrix.items():
            avg_mi[sym1] += mi
            avg_mi[sym2] += mi
            counts[sym1] += 1
            counts[sym2] += 1
            
        # Normalize
        for sym in avg_mi:
            if counts[sym] > 0:
                avg_mi[sym] /= counts[sym]
                
        # Return highest
        return max(avg_mi, key=avg_mi.get)


# Example usage
if __name__ == "__main__":
    # Generate synthetic data with varying predictability
    np.random.seed(42)
    
    # Period 1: Trending (predictable)
    trend = np.linspace(100, 110, 100) + np.random.randn(100) * 0.3
    
    # Period 2: Random (unpredictable)
    random_walk = 105 + np.cumsum(np.random.randn(100) * 0.5)
    
    # Period 3: Cyclical (moderately predictable)
    t = np.linspace(0, 4*np.pi, 100)
    cyclical = 105 + np.sin(t) * 3 + np.random.randn(100) * 0.2
    
    calculator = SignalPowerCalculator(lookback=50)
    
    for name, prices in [
        ("trending", trend),
        ("random", random_walk),
        ("cyclical", cyclical)
    ]:
        metrics = calculator.calculate(name, prices)
        print(f"\n{name.upper()}:")
        print(f"  Overall Signal Power: {metrics.overall_power:.3f}")
        print(f"  Shannon Entropy: {metrics.shannon_entropy:.3f}")
        print(f"  Mutual Information: {metrics.mutual_information:.3f}")
        print(f"  SNR (dB): {metrics.snr_db:.2f}")
        print(f"  Confidence: {metrics.confidence:.3f}")
