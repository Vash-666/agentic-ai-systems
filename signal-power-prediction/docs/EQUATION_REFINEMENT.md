# Signal Power Equations - Deep Analysis & Refinement

## Current Equations

```
Signal Power = Mutual Information × Spectral Energy / Entropy
Prediction = Σ (w_i × f_i) where w_i ∝ IC_i²
Variance = Σ (w_i² × σ_i²)
```

---

## Equation 1: Signal Power

### Current Form
```
SP = MI × SE / H
```

Where:
- **MI** = Mutual Information (predictive power between variables)
- **SE** = Spectral Energy (concentration in frequency domain)
- **H** = Shannon Entropy (uncertainty/disorder)

### Analysis

**Strengths:**
- MI captures predictive relationships
- SE identifies periodic/structured components
- Entropy penalizes randomness

**Weaknesses:**
1. **Dimensional inconsistency** - MI (bits), SE (energy units), H (bits) don't combine cleanly
2. **No normalization** - ranges unbounded, hard to interpret
3. **Linear multiplication** - assumes independence between terms
4. **No time decay** - old signals weighted equally
5. **Missing risk component** - high signal power could mean high volatility

### Refined Version

```
Signal Power = α × [MI_norm^β] × [SE_concentration^γ] × [1 - H_norm^δ] × R_adjustment
```

Where:
- **MI_norm** = MI / MI_max ∈ [0,1] (normalized)
- **SE_concentration** = 1 - (H_spectral / H_max) ∈ [0,1] (spectral entropy inverse)
- **H_norm** = H / H_max ∈ [0,1] (normalized Shannon entropy)
- **R_adjustment** = 1 / (1 + λ × σ²) (risk penalty, λ = risk aversion)
- **α, β, γ, δ** = learned exponents (default: β=1, γ=0.5, δ=2)

**Alternative (Simpler):**
```
Signal Power = IC × (1 - H_norm) × SE_concentration / (1 + σ²/σ²_max)
```

---

## Equation 2: Ensemble Prediction

### Current Form
```
ŷ = Σ w_i × f_i,  where w_i ∝ IC_i²
```

Where:
- **w_i** = weight for model i
- **f_i** = forecast from model i
- **IC_i** = Information Coefficient for model i

### Analysis

**Strengths:**
- IC² naturally weights by predictive power
- Simple and interpretable
- Proven in quantitative finance

**Weaknesses:**
1. **No confidence weighting** - high IC but low confidence gets same weight
2. **No correlation penalty** - correlated models get over-weighted
3. **Static weights** - doesn't adapt to regime changes
4. **No model diversity bonus** - doesn't reward uncorrelated predictions
5. **Sign ambiguity** - IC² loses directional information

### Refined Version

**Option A: Diversification-Adjusted Weighting**
```
w_i = |IC_i|^κ × C_i^λ / Σ_j |IC_j|^κ × C_j^λ
```

Where:
- **C_i** = confidence score (0-1)
- **κ** = IC exponent (typically 1-2, use 1 to preserve sign)
- **λ** = confidence exponent (typically 0.5-1)

**Option B: Covariance-Penalized (Markowitz-style)**
```
w = argmax_w [w^T μ - (γ/2) w^T Σ w]

subject to: Σ w_i = 1, w_i ≥ 0
```

Where:
- **μ** = vector of model ICs
- **Σ** = covariance matrix of model predictions
- **γ** = risk aversion parameter

**Option C: Bayesian Model Averaging (Recommended)**
```
w_i = P(M_i | D) = P(D | M_i) × P(M_i) / Σ_j P(D | M_j) × P(M_j)

P(D | M_i) ∝ exp(-BIC_i / 2) ≈ exp(-n × IC_i² / 2)
```

Where:
- **P(M_i | D)** = posterior probability of model i given data
- **BIC** = Bayesian Information Criterion
- **n** = number of observations

**Practical Implementation:**
```
w_i = exp(τ × IC_i × C_i) / Σ_j exp(τ × IC_j × C_j)
```

Where **τ** = temperature parameter (inverse, higher = more selective)

---

## Equation 3: Prediction Variance

### Current Form
```
σ²_pred = Σ w_i² × σ_i²
```

### Analysis

**Strengths:**
- Standard formula for weighted variance
- Penalizes high individual variances

**Weaknesses:**
1. **Ignores covariance** - models may be correlated, increasing true variance
2. **No model uncertainty** - doesn't account for model misspecification
3. **Static** - doesn't adapt to changing market conditions
4. **Underestimates** - typically produces too-narrow confidence intervals

### Refined Version

**Full Covariance Form:**
```
σ²_pred = Σ_i Σ_j w_i × w_j × σ_ij + σ²_model + σ²_regime
```

Where:
- **σ_ij** = covariance between model i and j predictions
- **σ²_model** = model uncertainty (epistemic)
- **σ²_regime** = regime-switching uncertainty

**Simplified (Diagonal + Correction):**
```
σ²_pred = Σ w_i² × σ_i² × (1 + ρ_avg × (k-1)) + σ²_market
```

Where:
- **ρ_avg** = average correlation between models
- **k** = number of models
- **σ²_market** = baseline market variance

**Bayesian Credible Interval:**
```
Var[ŷ] = E[Var[ŷ|θ]] + Var[E[ŷ|θ]]

       = Σ w_i × σ_i²  +  Σ w_i × (f_i - ŷ)²
         └─ within-model ─┘  └─ between-model ─┘
```

---

## Unified Refined System

### Recommended Implementation

```python
# 1. Calculate Signal Power for each model
for model in models:
    mi_norm = model.mutual_info / MAX_MI
    se_conc = 1 - (model.spectral_entropy / MAX_ENTROPY)
    h_norm = model.shannon_entropy / MAX_ENTROPY
    risk_adj = 1 / (1 + RISK_AVERSION * model.volatility**2)
    
    model.signal_power = (
        mi_norm * 
        (1 - h_norm)**2 * 
        se_conc**0.5 * 
        risk_adj
    )

# 2. Calculate Information Coefficient with decay
for model in models:
    returns = model.prediction_history
    actuals = model.actual_history
    weights = exponential_decay(len(returns), half_life=30)
    
    model.ic = weighted_spearman_correlation(returns, actuals, weights)
    model.confidence = model.signal_power * model.prediction_consistency

# 3. Calculate ensemble weights (softmax with diversity)
ic_matrix = compute_ic_correlation_matrix(models)
diversity_bonus = 1 / (1 + average_correlation(ic_matrix))

for model in models:
    score = model.ic * model.confidence * diversity_bonus
    model.weight = exp(TEMPERATURE * score)

normalize_weights(models)

# 4. Ensemble prediction
ensemble_pred = sum(m.weight * m.forecast for m in models)

# 5. Variance with covariance adjustment
variance_within = sum(m.weight**2 * m.variance for m in models)
variance_between = sum(m.weight * (m.forecast - ensemble_pred)**2 for m in models)
covariance_adj = 1 + AVG_CORRELATION * (len(models) - 1)

ensemble_variance = (variance_within + variance_between) * covariance_adj

# 6. Final output with confidence interval
confidence_interval = 1.96 * sqrt(ensemble_variance)
```

### Final Refined Equations

```
┌─────────────────────────────────────────────────────────────────┐
│                    REFINED EQUATIONS                             │
└─────────────────────────────────────────────────────────────────┘

SIGNAL POWER:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  SP_i = MI_norm × (1 - H_norm)² × √SE_conc × (1 + λσ²)^(-1)    │
│                                                                 │
│  Where:                                                         │
│  • MI_norm = MI_i / MI_max ∈ [0,1]                             │
│  • H_norm = H_i / H_max ∈ [0,1]                                │
│  • SE_conc = 1 - H_spectral / H_max ∈ [0,1]                    │
│  • λ = risk aversion parameter                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

ENSEMBLE WEIGHT:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│       exp[τ × IC_i × C_i × (1 + D_i)]                           │
│  w_i = ─────────────────────────────────                        │
│        Σ_j exp[τ × IC_j × C_j × (1 + D_j)]                      │
│                                                                 │
│  Where:                                                         │
│  • IC_i = time-decayed information coefficient                  │
│  • C_i = confidence = SP_i × consistency_i                     │
│  • D_i = diversity bonus = 1 / (1 + ρ̄_i)                       │
│  • τ = temperature (selectivity)                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

PREDICTION:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ŷ = Σ w_i × f_i                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

VARIANCE:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  σ² = [Σ w_i²σ_i² + Σ w_i(f_i - ŷ)²] × [1 + ρ̄(k-1)]           │
│       └─ within ─┘   └─ between ─┘   └─ covariance ─┘          │
│                                                                 │
│  Where:                                                         │
│  • ρ̄ = average pairwise correlation between models             │
│  • k = number of models                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

CONFIDENCE INTERVAL:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  CI_95% = ŷ ± 1.96 × σ                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Improvements Summary

| Aspect | Original | Refined |
|--------|----------|---------|
| **Normalization** | Unbounded | [0,1] normalized |
| **Risk** | Ignored | Explicit penalty |
| **Time decay** | None | Exponential decay |
| **Confidence** | Not used | Core component |
| **Diversity** | Ignored | Bonus for uncorrelated |
| **Covariance** | Ignored | Explicit adjustment |
| **Regime** | Static | Adaptive |
| **Interpretability** | Moderate | High |

---

## Hyperparameter Recommendations

```python
# Signal Power
RISK_AVERSION = 2.0          # λ: higher = more risk-sensitive
MAX_MI = 2.0                 # bits: theoretical max for discretized data
MAX_ENTROPY = 6.0            # bits: log2(bins) for 50 bins

# Ensemble
TEMPERATURE = 3.0            # τ: higher = more selective
IC_DECAY_HALFLIFE = 30       # days: how fast old IC fades
MIN_CONFIDENCE = 0.3         # threshold for inclusion

# Variance
CORRELATION_CAP = 0.5        # max ρ̄ to prevent over-correction
MARKET_VARIANCE_FLOOR = 0.001  # minimum variance (0.1% daily)
```

---

## Validation Metrics

To verify the refined equations work better:

1. **Information Coefficient** of final ensemble (target: > 0.05)
2. **Directional Accuracy** (target: > 52%)
3. **Sharpe Ratio** of signal (target: > 0.5)
4. **Calibration** - predicted vs actual variance (target: ratio 0.8-1.2)
5. **Maximum Drawdown** (target: < 20%)
