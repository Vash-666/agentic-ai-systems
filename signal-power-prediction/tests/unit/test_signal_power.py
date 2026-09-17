"""Unit tests for signal power calculation."""

import numpy as np
import pytest

from src.analysis.signal_power import (
    InformationCalculator, SpectralAnalyzer, SignalPowerCalculator
)


class TestInformationCalculator:
    """Test information theory calculations."""
    
    def test_shannon_entropy(self):
        """Test Shannon entropy calculation."""
        # Uniform distribution = high entropy
        uniform = np.random.randn(1000)
        entropy_uniform = InformationCalculator.shannon_entropy(uniform)
        
        # Concentrated distribution = low entropy
        concentrated = np.ones(1000) + np.random.randn(1000) * 0.01
        entropy_concentrated = InformationCalculator.shannon_entropy(concentrated)
        
        assert entropy_uniform > entropy_concentrated
        
    def test_mutual_information(self):
        """Test mutual information calculation."""
        # Perfect correlation
        x = np.linspace(0, 10, 100)
        y = x + np.random.randn(100) * 0.1
        
        mi = InformationCalculator.mutual_information(x, y)
        assert mi > 0.5  # Should be high
        
        # No correlation
        x_random = np.random.randn(100)
        y_random = np.random.randn(100)
        
        mi_random = InformationCalculator.mutual_information(x_random, y_random)
        assert mi_random < mi  # Should be lower
        
    def test_information_coefficient(self):
        """Test information coefficient calculation."""
        # Perfect prediction
        predictions = np.linspace(0, 10, 100)
        actuals = predictions + np.random.randn(100) * 0.1
        
        ic = InformationCalculator.information_coefficient(predictions, actuals)
        assert ic > 0.8  # Should be high
        
        # Random prediction
        random_preds = np.random.randn(100)
        ic_random = InformationCalculator.information_coefficient(random_preds, actuals)
        assert abs(ic_random) < 0.3  # Should be low


class TestSpectralAnalyzer:
    """Test spectral analysis."""
    
    def test_psd_calculation(self):
        """Test power spectral density."""
        # Sine wave should have peak at specific frequency
        t = np.linspace(0, 10, 1000)
        sine_wave = np.sin(2 * np.pi * 5 * t)  # 5 Hz
        
        f, psd = SpectralAnalyzer.power_spectral_density(sine_wave, fs=100)
        
        assert len(f) == len(psd)
        assert len(psd) > 0
        
        # Peak should be near 5 Hz
        dominant_freq = SpectralAnalyzer.dominant_frequency(f, psd)
        assert 4 < dominant_freq < 6
        
    def test_spectral_energy(self):
        """Test spectral energy calculation."""
        psd = np.array([1.0, 2.0, 3.0, 2.0, 1.0])
        energy = SpectralAnalyzer.spectral_energy(psd)
        
        assert energy == 9.0
        
    def test_spectral_entropy(self):
        """Test spectral entropy."""
        # Uniform spectrum = high entropy
        uniform_psd = np.ones(100)
        entropy_uniform = SpectralAnalyzer.spectral_entropy(uniform_psd)
        
        # Concentrated spectrum = low entropy
        concentrated_psd = np.zeros(100)
        concentrated_psd[50] = 1.0
        entropy_concentrated = SpectralAnalyzer.spectral_entropy(concentrated_psd)
        
        assert entropy_uniform > entropy_concentrated


class TestSignalPowerCalculator:
    """Test signal power calculator."""
    
    def test_initialization(self):
        """Test calculator initialization."""
        calc = SignalPowerCalculator(lookback=100, mi_lookback=20)
        assert calc.lookback == 100
        assert calc.mi_lookback == 20
        
    def test_snr_calculation(self):
        """Test SNR calculation."""
        calc = SignalPowerCalculator()
        
        # High SNR (clean trend)
        trend = np.linspace(100, 110, 100)
        snr, sig_power, noise_power = calc.calculate_snr(trend)
        
        assert snr > 10  # Should be high
        assert sig_power > noise_power
        
    def test_full_calculation(self):
        """Test full signal power calculation."""
        calc = SignalPowerCalculator()
        
        # Generate test data
        prices = np.linspace(100, 110, 100) + np.random.randn(100) * 0.5
        
        metrics = calc.calculate("TEST", prices)
        
        assert metrics.symbol == "TEST"
        assert 0 <= metrics.overall_power <= 1
        assert 0 <= metrics.confidence <= 1
        assert metrics.snr_db is not None
        
    def test_predictable_vs_random(self):
        """Test that predictable data has higher signal power."""
        calc = SignalPowerCalculator()
        
        # Predictable (trending)
        trend = np.linspace(100, 120, 100) + np.random.randn(100) * 0.3
        metrics_trend = calc.calculate("TREND", trend)
        
        # Random
        random_walk = 110 + np.cumsum(np.random.randn(100) * 0.5)
        metrics_random = calc.calculate("RANDOM", random_walk)
        
        # Trend should have higher signal power
        assert metrics_trend.overall_power > metrics_random.overall_power
