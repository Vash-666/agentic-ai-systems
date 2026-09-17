"""
Kalman filter for optimal signal extraction from noisy market data.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Optional, Tuple
from filterpy.kalman import KalmanFilter
import structlog

logger = structlog.get_logger()


@dataclass
class KalmanState:
    """State estimate from Kalman filter."""
    timestamp: float
    price_estimate: float
    velocity_estimate: float
    uncertainty: float
    gain: float
    residual: float


class PriceKalmanFilter:
    """
    Kalman filter for price tracking and prediction.
    
    State vector: [price, velocity]
    - Price: current best estimate of true price
    - Velocity: rate of price change (momentum)
    
    Measurement: observed price (with noise)
    """
    
    def __init__(
        self,
        process_noise: float = 0.01,
        measurement_noise: float = 1.0,
        initial_uncertainty: float = 100.0
    ):
        """
        Initialize Kalman filter.
        
        Args:
            process_noise: Q - uncertainty in model (higher = more flexible)
            measurement_noise: R - uncertainty in measurements (higher = trust data less)
            initial_uncertainty: Initial state covariance
        """
        self.kf = KalmanFilter(dim_x=2, dim_z=1)
        
        # State transition matrix
        # x = [price, velocity]
        # x[t+1] = x[t] + velocity * dt
        # velocity[t+1] = velocity[t] (random walk)
        self.kf.F = np.array([
            [1.0, 1.0],  # price += velocity
            [0.0, 1.0]   # velocity persists
        ])
        
        # Measurement function
        # We only observe price, not velocity
        self.kf.H = np.array([[1.0, 0.0]])
        
        # Process noise covariance
        self.kf.Q = np.array([
            [process_noise, 0.0],
            [0.0, process_noise * 0.1]  # Velocity changes slower
        ])
        
        # Measurement noise covariance
        self.kf.R = np.array([[measurement_noise]])
        
        # Initial state covariance
        self.kf.P = np.eye(2) * initial_uncertainty
        
        # Initial state (will be set on first measurement)
        self.kf.x = np.array([[0.0], [0.0]])
        
        self.initialized = False
        self.history: List[KalmanState] = []
        
    def initialize(self, price: float):
        """Initialize filter with first price observation."""
        self.kf.x = np.array([[price], [0.0]])
        self.initialized = True
        logger.info("Kalman filter initialized", initial_price=price)
        
    def update(self, price: float, timestamp: float = None) -> KalmanState:
        """
        Update filter with new price observation.
        
        Args:
            price: Observed price
            timestamp: Optional timestamp
            
        Returns:
            KalmanState with estimates
        """
        if not self.initialized:
            self.initialize(price)
            return KalmanState(
                timestamp=timestamp or 0.0,
                price_estimate=price,
                velocity_estimate=0.0,
                uncertainty=float(self.kf.P[0, 0]),
                gain=0.0,
                residual=0.0
            )
            
        # Predict step
        self.kf.predict()
        
        # Update step
        self.kf.update(np.array([[price]]))
        
        # Extract state
        state = KalmanState(
            timestamp=timestamp or len(self.history),
            price_estimate=float(self.kf.x[0, 0]),
            velocity_estimate=float(self.kf.x[1, 0]),
            uncertainty=float(self.kf.P[0, 0]),
            gain=float(self.kf.K[0, 0]),
            residual=float(self.kf.y[0, 0])  # Innovation
        )
        
        self.history.append(state)
        return state
        
    def predict(self, steps: int = 1) -> List[Tuple[float, float]]:
        """
        Predict future prices.
        
        Args:
            steps: Number of steps to predict
            
        Returns:
            List of (price_estimate, uncertainty) tuples
        """
        if not self.initialized:
            return []
            
        predictions = []
        x_pred = self.kf.x.copy()
        P_pred = self.kf.P.copy()
        
        for _ in range(steps):
            # Predict one step
            x_pred = self.kf.F @ x_pred
            P_pred = self.kf.F @ P_pred @ self.kf.F.T + self.kf.Q
            
            price_est = float(x_pred[0, 0])
            uncertainty = float(np.sqrt(P_pred[0, 0]))
            predictions.append((price_est, uncertainty))
            
        return predictions
        
    def get_signal(self, current_price: float) -> float:
        """
        Generate trading signal from filter state.
        
        Returns:
            Signal from -1 (strong sell) to +1 (strong buy)
            Based on velocity and price vs estimate
        """
        if not self.initialized or not self.history:
            return 0.0
            
        state = self.history[-1]
        
        # Normalize velocity by uncertainty
        if state.uncertainty > 0:
            normalized_velocity = state.velocity_estimate / np.sqrt(state.uncertainty)
        else:
            normalized_velocity = 0.0
            
        # Price deviation from estimate
        price_deviation = (current_price - state.price_estimate) / max(state.uncertainty, 0.01)
        
        # Combine signals
        signal = np.tanh(normalized_velocity * 0.5 + price_deviation * 0.3)
        
        return float(signal)
        
    def get_trend_confidence(self) -> float:
        """
        Get confidence in current trend direction.
        
        Returns:
            Confidence from 0 (uncertain) to 1 (certain)
        """
        if not self.history:
            return 0.0
            
        state = self.history[-1]
        
        # Higher uncertainty = lower confidence
        uncertainty_factor = 1.0 / (1.0 + state.uncertainty / 100.0)
        
        # Higher velocity magnitude = more confident in trend
        velocity_magnitude = min(abs(state.velocity_estimate) / 5.0, 1.0)
        
        return uncertainty_factor * velocity_magnitude


class AdaptiveKalmanFilter:
    """
    Kalman filter with adaptive noise estimation.
    
    Automatically adjusts process and measurement noise
    based on recent prediction errors.
    """
    
    def __init__(
        self,
        initial_process_noise: float = 0.01,
        initial_measurement_noise: float = 1.0,
        adaptation_window: int = 20
    ):
        """
        Initialize adaptive filter.
        
        Args:
            initial_process_noise: Starting process noise
            initial_measurement_noise: Starting measurement noise
            adaptation_window: Window for error estimation
        """
        self.kf = PriceKalmanFilter(
            process_noise=initial_process_noise,
            measurement_noise=initial_measurement_noise
        )
        
        self.adaptation_window = adaptation_window
        self.residuals: List[float] = []
        self.base_Q = initial_process_noise
        self.base_R = initial_measurement_noise
        
    def update(self, price: float, timestamp: float = None) -> KalmanState:
        """Update with adaptive noise adjustment."""
        state = self.kf.update(price, timestamp)
        
        # Track residuals for adaptation
        self.residuals.append(abs(state.residual))
        if len(self.residuals) > self.adaptation_window:
            self.residuals.pop(0)
            
        # Adapt noise parameters
        if len(self.residuals) >= self.adaptation_window:
            self._adapt_noise()
            
        return state
        
    def _adapt_noise(self):
        """Adapt noise parameters based on recent residuals."""
        mean_residual = np.mean(self.residuals)
        std_residual = np.std(self.residuals)
        
        # If residuals are large and variable, increase process noise
        # (market is changing, model needs to adapt)
        if mean_residual > 2.0 * np.sqrt(self.kf.kf.R[0, 0]):
            new_Q = self.base_Q * 2.0
            new_R = self.base_R * 0.5  # Trust measurements more
        elif std_residual < 0.5:
            # Low variance - market is stable
            new_Q = self.base_Q * 0.5
            new_R = self.base_R * 1.0
        else:
            new_Q = self.base_Q
            new_R = self.base_R
            
        self.kf.kf.Q = np.array([
            [new_Q, 0.0],
            [0.0, new_Q * 0.1]
        ])
        self.kf.kf.R = np.array([[new_R]])
        
    def predict(self, steps: int = 1) -> List[Tuple[float, float]]:
        """Predict future prices."""
        return self.kf.predict(steps)
        
    def get_signal(self, current_price: float) -> float:
        """Generate trading signal."""
        return self.kf.get_signal(current_price)


class MultiSymbolKalmanTracker:
    """
    Track multiple symbols with individual Kalman filters.
    """
    
    def __init__(self, symbols: List[str], **kwargs):
        """
        Initialize tracker for multiple symbols.
        
        Args:
            symbols: List of symbols to track
            **kwargs: Arguments passed to PriceKalmanFilter
        """
        self.symbols = symbols
        self.filters = {
            symbol: PriceKalmanFilter(**kwargs)
            for symbol in symbols
        }
        
    def update(self, symbol: str, price: float, timestamp: float = None) -> Optional[KalmanState]:
        """Update filter for a symbol."""
        if symbol not in self.filters:
            logger.warning("Unknown symbol", symbol=symbol)
            return None
            
        return self.filters[symbol].update(price, timestamp)
        
    def get_state(self, symbol: str) -> Optional[KalmanState]:
        """Get current state for a symbol."""
        if symbol not in self.filters:
            return None
            
        kf = self.filters[symbol]
        if not kf.history:
            return None
            
        return kf.history[-1]
        
    def get_all_signals(self) -> dict:
        """Get signals for all symbols."""
        signals = {}
        for symbol, kf in self.filters.items():
            if kf.history:
                state = kf.history[-1]
                signals[symbol] = {
                    'signal': kf.get_signal(state.price_estimate),
                    'price_estimate': state.price_estimate,
                    'velocity': state.velocity_estimate,
                    'uncertainty': state.uncertainty,
                    'confidence': kf.get_trend_confidence()
                }
        return signals


# Example usage
if __name__ == "__main__":
    # Generate noisy price data with underlying trend
    np.random.seed(42)
    
    true_prices = []
    observed_prices = []
    
    price = 100.0
    velocity = 0.1
    
    for i in range(200):
        # True price with momentum
        price += velocity + np.random.randn() * 0.05
        velocity += np.random.randn() * 0.01
        velocity = np.clip(velocity, -0.5, 0.5)
        
        # Add measurement noise
        observed = price + np.random.randn() * 0.5
        
        true_prices.append(price)
        observed_prices.append(observed)
        
    # Apply Kalman filter
    kf = PriceKalmanFilter(
        process_noise=0.01,
        measurement_noise=1.0
    )
    
    estimates = []
    signals = []
    
    for obs in observed_prices:
        state = kf.update(obs)
        estimates.append(state.price_estimate)
        signals.append(kf.get_signal(obs))
        
    # Print results
    print("Kalman Filter Results:")
    print(f"Final true price: {true_prices[-1]:.2f}")
    print(f"Final observed: {observed_prices[-1]:.2f}")
    print(f"Final estimate: {estimates[-1]:.2f}")
    print(f"Final velocity: {kf.history[-1].velocity_estimate:.4f}")
    print(f"Final signal: {signals[-1]:+.3f}")
    
    # Predict next 5 prices
    predictions = kf.predict(steps=5)
    print("\nPredictions:")
    for i, (price, unc) in enumerate(predictions):
        print(f"  t+{i+1}: ${price:.2f} ± ${unc:.2f}")
