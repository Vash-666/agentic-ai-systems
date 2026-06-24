# Signal Power Prediction System - Architecture

## Overview

Real-time financial market prediction using signal processing, information theory, and Bayesian ensemble methods.

## Core Equation

```
Signal Power = Mutual Information × Spectral Energy / Entropy

Prediction = Σ (w_i × f_i) where w_i ∝ IC_i²

Variance = Σ (w_i² × σ_i²)
```

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SIGNAL POWER SYSTEM                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  LAYER 1: INGESTION (Real-time)                                  │
├─────────────────────────────────────────────────────────────────┤
│  • WebSocket feeds (Polygon, Alpaca)                            │
│  • Multi-market data (stocks, forex, crypto)                    │
│  • Tick buffering & batching                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 2: TRANSFORM (Signal Processing)                          │
├─────────────────────────────────────────────────────────────────┤
│  Wavelet Decomposition          Kalman Filtering                │
│  • Regime detection             • Optimal state estimation      │
│  • Trend/range/volatile         • Noise reduction               │
│  • Multi-scale analysis         • Velocity tracking             │
│  • Energy distribution          • Prediction                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 3: ANALYSIS (Signal Power)                                │
├─────────────────────────────────────────────────────────────────┤
│  Information Theory            Spectral Analysis                │
│  • Shannon entropy             • Power spectral density         │
│  • Mutual information          • Dominant frequency             │
│  • Information coefficient     • Spectral entropy               │
│                                                                 │
│  Signal-to-Noise Ratio         Cross-Market                     │
│  • Trend vs noise power        • Lead-lag detection             │
│  • SNR in dB                   • Predictive relationships       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 4: PREDICTION (Ensemble)                                  │
├─────────────────────────────────────────────────────────────────┤
│  Model Predictions:                                             │
│  • Wavelet regime signal        • Kalman trend/velocity         │
│  • Momentum signals             • Cross-market signals          │
│                                                                 │
│  Bayesian Model Averaging:                                      │
│  • Weight by IC² (information coefficient squared)              │
│  • Confidence-weighted combination                              │
│  • Variance estimation                                          │
│                                                                 │
│  Output:                                                        │
│  • Ensemble signal (-1 to +1)                                   │
│  • Expected return                                              │
│  • Prediction variance                                          │
│  • Trading recommendation (buy/sell/hold)                       │
│  • Position size (0-100%)                                       │
└─────────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Wavelet Analyzer (`transform/wavelet_decomp.py`)

**Purpose:** Detect market regimes (trending/ranging/volatile)

**Method:**
- Discrete Wavelet Transform (DWT) with Daubechies 4 wavelet
- Decompose price into 5 frequency levels
- Classify regime by energy distribution

**Output:**
- Regime classification
- Trend strength (0-1)
- Volatility estimate
- Consensus signal across multiple time scales

### 2. Kalman Filter (`transform/kalman_filter.py`)

**Purpose:** Extract true price signal from noise

**State Vector:** `[price, velocity]`

**Method:**
- Predict-update cycle
- Adaptive noise estimation
- Optimal state estimation

**Output:**
- Smoothed price estimate
- Velocity (momentum)
- Prediction uncertainty
- Trading signal

### 3. Signal Power Calculator (`analysis/signal_power.py`)

**Purpose:** Quantify predictive power using physics & information theory

**Metrics:**
- Shannon entropy (predictability)
- Mutual information (autocorrelation)
- Information coefficient (prediction quality)
- Spectral energy (frequency domain power)
- SNR (signal-to-noise ratio)

**Output:**
- Overall signal power (0-1)
- Confidence score
- Cross-market predictive relationships

### 4. Ensemble Predictor (`prediction/ensemble.py`)

**Purpose:** Combine multiple signals optimally

**Method:**
- Bayesian Model Averaging
- Weight = IC² (information coefficient squared)
- Adaptive weight updating

**Output:**
- Ensemble prediction
- Model weights
- Recommendation with position sizing

## Data Flow

```
Tick → Buffer → Price History → Parallel Processing:
                                      │
    ┌─────────────────────────────────┼─────────────────────────────────┐
    │                                 │                                 │
    ▼                                 ▼                                 ▼
Wavelet Analysis              Kalman Filter                    Signal Power
    │                                 │                                 │
    ▼                                 ▼                                 ▼
Regime Signal                 Trend/Velocity                   IC/MI/Entropy
    │                                 │                                 │
    └─────────────────────────────────┼─────────────────────────────────┘
                                      │
                                      ▼
                           Ensemble Predictor
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
               Weighted Avg      Variance Est     Recommendation
```

## Configuration

Environment variables (see `.env.example`):

```bash
# API Keys
POLYGON_API_KEY=xxx
ALPACA_API_KEY=xxx
ALPACA_SECRET_KEY=xxx

# Markets
STOCKS=AAPL,MSFT,GOOGL
FOREX=EURUSD,GBPUSD
CRYPTO=BTCUSD,ETHUSD

# Processing
WAVELET_NAME=db4
WAVELET_LEVELS=5
KALMAN_PROCESS_NOISE=0.01
KALMAN_MEASUREMENT_NOISE=1.0
```

## Performance Considerations

- **Latency:** WebSocket ingestion < 100ms
- **Processing:** Wavelet/Kalman < 10ms per symbol
- **Memory:** 200 price points per symbol (~1.6KB)
- **Throughput:** 1000+ ticks/second

## Future Enhancements

1. **Deep Learning:** LSTM for sequence prediction
2. **Reinforcement Learning:** Optimal position sizing
3. **Alternative Data:** News sentiment, order flow
4. **GPU Acceleration:** Parallel wavelet transforms
5. **Distributed:** Multi-node processing
