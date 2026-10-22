# Data Quality Assessment

**Source:** [Kaggle — Healthcare Dataset Stroke Data](https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset)  
**Raw file:** `data/raw/healthcare-dataset-stroke-data.csv`  
**Rows × columns:** 5,110 × 12  
**Grain:** One row = one patient assessment  

---

## Executive summary

The dataset is usable for a portfolio dashboard after targeted cleaning. Main risks are **missing BMI (not random)**, **high “Unknown” smoking status**, **class imbalance (~4.9% stroke)**, and **inconsistent encodings**. No duplicate patient IDs were found.

---

## Issue register

| # | Issue | Severity | Evidence | Handling (Power Query) |
|---|--------|----------|----------|-------------------------|
| 1 | Missing BMI stored as text `"N/A"` | High | 201 values are the literal string `N/A` (3.93%), not blanks. Power Query errors if you cast BMI to Number first. Stroke rate 19.9% if missing vs 4.26% if present | Replace `"N/A"` → null, then type as number; flag `bmi_is_missing`; impute `bmi_imputed` via median by age band × gender; never drop rows |
| 2 | Smoking = Unknown | High | 1,544 rows (30.2%); 79.7% of ages &lt;18 | Keep as category; add `smoking_is_known` |
| 3 | Mixed binary formats | Medium | HTN/heart/stroke = 0/1; married = Yes/No | Add `*_label` Yes/No columns; keep numeric for measures |
| 4 | `work_type = children` | Medium | Not employment; ages 0.08–16 | Map to `Child / Not in workforce`; add `is_pediatric` |
| 5 | Inconsistent column name | Low | `Residence_type` | Rename to `residence_type` |
| 6 | Gender = Other | Low | 1 row | Keep; filter out of gender charts if needed |
| 7 | Fractional ages | Low | Min 0.08; infant ages in years | Keep `age`; add `age_years`, `age_band` |
| 8 | BMI outliers | Low | Max 97.6; 79 rows &gt;50 | Keep; band as Obese; optional outlier flag later |
| 9 | Class imbalance | Design | 249 strokes / 4,861 non-strokes (~1:19.5) | Report **rates & relative risk**, not counts alone |
| 10 | Duplicates | None | 0 duplicate `id`s | Key validated |

---

## Profile snapshots

### Target
- Stroke = 1: **249 (4.87%)**  
- Stroke = 0: **4,861 (95.13%)**

### Categoricals
| Column | Values |
|--------|--------|
| gender | Female 58.6%, Male 41.4%, Other 0.02% |
| smoking_status (raw) | never smoked 37.0%, Unknown 30.2%, formerly smoked 17.3%, smokes 15.4% — cleaned labels: Never smoked / Formerly smoked / Smokes / Unknown |
| work_type | Private 57.2%, Self-employed 16.0%, children 13.4%, Govt_job 12.9%, Never_worked 0.4% |
| residence_type | Urban 50.8%, Rural 49.2% |

### Numerics
| Column | Min | Median | Max | Notes |
|--------|-----|--------|-----|-------|
| age | 0.08 | 45 | 82 | Includes infants |
| avg_glucose_level | 55.12 | 91.89 | 271.74 | Right-skewed |
| bmi (non-null) | 10.3 | 28.1 | 97.6 | 201 missing |

---

## Decision log (portfolio narrative)

1. **Missing BMI is a signal, not only a defect** — retained and flagged.  
2. **Imputation is transparent** — original `bmi` kept; `bmi_is_imputed` marks replacements.  
3. **Unknown smoking is not recoded** to “never smoked” — that would bias lifestyle analysis.  
4. **Derived bands** (age / BMI / glucose) and **clinical_profile** prepare the star-schema dimensions.

---

## Acceptance criteria

- [x] Issues documented  
- [x] M script implements handling  
- [x] Validated 5,110 rows in Power BI  
