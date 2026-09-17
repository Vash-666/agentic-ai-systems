# Refined Equations - Executive Summary

## Original vs Refined

### Original Equations
```
Signal Power = MI × SE / H
Prediction = Σ w_i × f_i,  w_i ∝ IC_i²
Variance = Σ w_i² × σ_i²
```

### Refined Equations
```
┌─────────────────────────────────────────────────────────────────┐
│  SIGNAL POWER                                                   │
│                                                                 │
│  SP = MI_norm × (1 - H_norm)² × √SE_conc × (1 + λσ²)^(-1)      │
│                                                                 │
│  Where:                                                         │
│  • MI_norm = MI / MI_max ∈ [0,1]                               │
│  • H_norm = H / H_max ∈ [0,1]                                  │
│  • SE_conc = spectral concentration ∈ [0,1]                    │
│  • λ = risk aversion (default: 2.0)                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ENSEMBLE WEIGHT                                                │
│                                                                 │
│       exp[τ × |IC_i| × C_i × (1 + D_i)]                         │
│  w_i = ───────────────────────────────────────                  │
│        Σ_j exp[τ × |IC_j| × C_j × (1 + D_j)]                    │
│                                                                 │
│  Where:                                                         │
│  • τ = temperature (default: 3.0)                              │
│  • C_i = confidence = SP_i × consistency_i                     │
│  • D_i = diversity bonus = 1/(1 + ρ̄_i)                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  PREDICTION                                                     │
│                                                                 │
│  ŷ = Σ w_i × f_i                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  VARIANCE                                                       │
│                                                                 │
│  σ² = [Σ w_i²σ_i² + Σ w_i(f_i - ŷ)²] × [1 + ρ̄(k-1)]           │
│       └─ within ─┘   └─ between ─┘   └─ covariance ─┘          │
│                                                                 │
│  Where:                                                         │
│  • ρ̄ = average correlation between models                      │
│  • k = number of models                                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  CONFIDENCE INTERVAL                                            │
│                                                                 │
│  CI_95% = ŷ ± 1.96 × σ                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Improvements

| Issue | Original | Refined | Impact |
|-------|----------|---------|--------|
| **Units** | Mixed (bits, energy) | All normalized [0,1] | Interpretable |
| **Risk** | Ignored | Explicit penalty | Safer predictions |
| **Time decay** | None | Exponential decay | Adaptive to changes |
| **Confidence** | Not used | Core component | Better weighting |
| **Diversity** | Ignored | Bonus for uncorrelated | Robust ensemble |
| **Covariance** | Ignored | Explicit adjustment | Accurate variance |
| **Regime** | Static | Adaptive IC | Better in changing markets |

---

## Physical Interpretation

### Signal Power
```
SP = (predictive_info) × (predictability)² × (structure)^0.5 / (risk)
```

- **MI_norm**: How much does past predict future?
- **(1-H_norm)²**: How predictable is the distribution? (squared to emphasize)
- **√SE_conc**: How much periodic structure exists? (square root for balance)
- **Risk adj**: Penalty for high volatility

### Ensemble Weight
```
weight ∝ exp(performance × confidence × diversity)
```

- **Softmax**: Natural probability distribution
- **Temperature**: Control selectivity (high τ = only best models)
- **Diversity bonus**: Reward uncorrelated predictions

### Variance
```
variance = (individual_uncertainty) + (disagreement) × (correlation_penalty)
```

- **Within**: Individual model uncertainties
- **Between**: How much models disagree
- **Covariance**: Penalty for correlated errors

---

## Default Parameters

```python
# Signal Power
MAX_MI = 2.0              # bits
MAX_ENTROPY = 6.0         # log2(50 bins)
RISK_AVERSION = 2.0       # λ

# Ensemble
TEMPERATURE = 3.0         # τ (higher = more selective)
MIN_CONFIDENCE = 0.3      # threshold for inclusion
CORRELATION_CAP = 0.5     # max correlation adjustment

# IC Decay
IC_HALFLIFE = 30          # days

# Variance
CONFIDENCE_Z = 1.96       # 95% CI
```

---

## Usage Example

```python
from src.analysis.refined_signal_power import RefinedSignalPowerCalculator
from src.prediction.refined_ensemble import RefinedEnsemblePredictor

# Calculate signal power
calc = RefinedSignalPowerCalculator()
metrics = calc.calculate("AAPL", prices, timestamp)
print(f"Signal Power: {metrics.signal_power:.3f}")

# Build ensemble
predictor = RefinedEnsemblePredictor("AAPL", temperature=3.0)
predictions = [
    predictor.add_prediction(
        source=SignalSource.WAVELET_REGIME,
        forecast=0.02,
        signal=0.6,
        confidence=metrics.confidence,
        ic=metrics.ic_decayed,
        variance=0.001,
        timestamp=timestamp
    ),
    # ... more predictions
]

# Get ensemble prediction
ensemble = predictor.calculate_ensemble(predictions, timestamp)
print(f"Forecast: {ensemble.ensemble_forecast:+.3f}")
print(f"95% CI: [{ensemble.confidence_interval_95[0]:+.3f}, {ensemble.confidence_interval_95[1]:+.3f}]")
print(f"Action: {ensemble.recommendation.upper()} {ensemble.position_size:.1%}")
```

---

## Validation Checklist

- [ ] Signal Power ∈ [0,1] ✓
- [ ] Weights sum to 1 ✓
- [ ] Variance ≥ 0 ✓
- [ ] IC time decay working ✓
- [ ] Diversity bonus increases with low correlation ✓
- [ ] Risk penalty decreases SP with high volatility ✓
- [ ] Confidence interval contains ~95% of actuals (backtest) ⏳
