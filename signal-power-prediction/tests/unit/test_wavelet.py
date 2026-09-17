"""Unit tests for wavelet decomposition."""

import numpy as np
import pytest

from src.transform.wavelet_decomp import (
    WaveletAnalyzer, MultiScaleAnalyzer, MarketRegime
)


class TestWaveletAnalyzer:
    """Test wavelet analyzer functionality."""
    
    def test_initialization(self):
        """Test analyzer initialization."""
        analyzer = WaveletAnalyzer(wavelet="db4", levels=5, lookback=128)
        assert analyzer.wavelet == "db4"
        assert analyzer.levels == 5
        assert analyzer.lookback == 128
        
    def test_decomposition(self):
        """Test wavelet decomposition."""
        analyzer = WaveletAnalyzer()
        prices = np.random.randn(128) + 100
        
        detail_coeffs, approximation = analyzer.decompose(prices)
        
        assert len(detail_coeffs) == analyzer.levels
        assert len(approximation) > 0
        
    def test_energy_calculation(self):
        """Test energy calculation."""
        analyzer = WaveletAnalyzer()
        prices = np.random.randn(128) + 100
        
        detail_coeffs, _ = analyzer.decompose(prices)
        energies = analyzer.calculate_energy(detail_coeffs)
        
        assert len(energies) == len(detail_coeffs)
        assert np.isclose(energies.sum(), 1.0)  # Normalized
        assert all(e >= 0 for e in energies)
        
    def test_trending_detection(self):
        """Test detection of trending market."""
        analyzer = WaveletAnalyzer()
        
        # Create trending data
        trend = np.linspace(100, 120, 128) + np.random.randn(128) * 0.5
        
        detail_coeffs, approximation = analyzer.decompose(trend)
        regime = analyzer.detect_regime(trend, detail_coeffs, approximation)
        
        assert regime in [MarketRegime.TRENDING_UP, MarketRegime.TRENDING_DOWN]
        
    def test_ranging_detection(self):
        """Test detection of ranging market."""
        analyzer = WaveletAnalyzer()
        
        # Create ranging data
        t = np.linspace(0, 8*np.pi, 128)
        ranging = 110 + np.sin(t) * 5 + np.random.randn(128) * 0.3
        
        detail_coeffs, approximation = analyzer.decompose(ranging)
        regime = analyzer.detect_regime(ranging, detail_coeffs, approximation)
        
        assert regime == MarketRegime.RANGING
        
    def test_signal_generation(self):
        """Test signal generation."""
        analyzer = WaveletAnalyzer()
        
        # Uptrend
        uptrend = np.linspace(100, 120, 128)
        features = analyzer.analyze("TEST", uptrend)
        signal = analyzer.get_regime_signal(features)
        
        assert signal > 0
        
        # Downtrend
        downtrend = np.linspace(120, 100, 128)
        features = analyzer.analyze("TEST", downtrend)
        signal = analyzer.get_regime_signal(features)
        
        assert signal < 0


class TestMultiScaleAnalyzer:
    """Test multi-scale analyzer."""
    
    def test_initialization(self):
        """Test multi-scale initialization."""
        scales = [32, 64, 128]
        analyzer = MultiScaleAnalyzer(scales=scales)
        
        assert analyzer.scales == scales
        assert len(analyzer.analyzers) == len(scales)
        
    def test_multi_scale_analysis(self):
        """Test analysis across multiple scales."""
        analyzer = MultiScaleAnalyzer(scales=[32, 64])
        prices = np.random.randn(128) + 100
        
        results = analyzer.analyze_all_scales("TEST", prices)
        
        assert 32 in results
        assert 64 in results
        
    def test_consensus_signal(self):
        """Test consensus signal calculation."""
        analyzer = MultiScaleAnalyzer(scales=[32, 64])
        prices = np.linspace(100, 110, 128)  # Clear uptrend
        
        results = analyzer.analyze_all_scales("TEST", prices)
        signal, confidence = analyzer.get_consensus_signal(results)
        
        assert -1 <= signal <= 1
        assert 0 <= confidence <= 1
