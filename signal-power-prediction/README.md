# Signal Power Prediction System

Real-time multi-market signal processing for financial prediction using wavelet decomposition, Kalman filtering, and information-theoretic signal weighting.

## Core Concept

Treat financial markets as physical signals. Extract predictive power using:
- **Wavelet analysis** → Regime detection (trending/ranging/volatile)
- **Kalman filtering** → Optimal signal extraction from noise
- **Mutual information** → Cross-market predictive relationships
- **Ensemble weighting** → Bayesian model averaging by information coefficient

## Architecture

```
Market Data APIs → Ingestion → Transform → Analysis → Prediction → Output
                    (WebSocket)  (Wavelet/  (Signal    (Ensemble   (Variance
                                 Kalman)    Power)     Weighting)   Estimate)
```

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
cp .env.example .env
# Edit .env with your API keys

# Run ingestion
python -m src.ingestion.websocket_feed

# Run full pipeline
python -m src.main
```

## Project Structure

```
signal-power-prediction/
├── src/
│   ├── ingestion/      # Real-time data feeds
│   ├── transform/      # Wavelet & Kalman processing
│   ├── analysis/       # Signal power calculation
│   ├── prediction/     # Ensemble output
│   └── utils/          # Shared utilities
├── tests/              # Test suite
├── config/             # Configuration files
├── docs/               # Documentation
└── .github/            # CI/CD workflows
```

## Signal Power Equation

```
Signal Power = Mutual Information × Spectral Energy / Entropy

Prediction = Σ (w_i × f_i) where w_i ∝ IC_i²

Variance = Σ (w_i² × σ_i²)
```

## License

MIT License - See LICENSE file
