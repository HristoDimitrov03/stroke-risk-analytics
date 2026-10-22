# Data Dictionary

## Raw columns (`data/raw`)

| Column | Type | Description |
|--------|------|-------------|
| id | Whole number | Unique patient identifier |
| gender | Text | Male / Female / Other |
| age | Decimal | Age in years (fractional for infants) |
| hypertension | 0/1 | 1 = patient has hypertension |
| heart_disease | 0/1 | 1 = patient has heart disease |
| ever_married | Text | Yes / No |
| work_type | Text | Private, Self-employed, Govt_job, children, Never_worked |
| Residence_type | Text | Urban / Rural |
| avg_glucose_level | Decimal | Average blood glucose level |
| bmi | Decimal | Body mass index (nulls present) |
| smoking_status | Text | Never smoked, Formerly smoked, Smokes, Unknown (capitalized in Power Query) |
| stroke | 0/1 | 1 = stroke event recorded |

---

## Columns added in Power Query (`StrokeRawCleaned`)

| Column | Type | Description |
|--------|------|-------------|
| patient_id | Whole number | Renamed from `id` |
| residence_type | Text | Renamed from `Residence_type` |
| age_years | Whole number | Floor of age |
| age_band | Text | 0-17, 18-39, 40-54, 55-64, 65-74, 75+ |
| is_pediatric | 0/1 | 1 if age &lt; 18 |
| work_type_clean | Text | Friendly work-type labels |
| hypertension_label | Text | Yes / No |
| heart_disease_label | Text | Yes / No |
| stroke_label | Text | Yes / No |
| clinical_profile | Text | Comorbidity group (HTN × heart disease) |
| glucose_band | Text | Screening-style glucose bands (not a diagnosis) |
| bmi_is_missing | 0/1 | 1 if original BMI was null |
| bmi_imputed | Decimal | Original BMI, or median by age_band × gender |
| bmi_is_imputed | 0/1 | 1 if BMI was imputed |
| bmi_band | Text | Underweight / Normal / Overweight / Obese / Missing |
| bmi_band_imputed | Text | BMI band using `bmi_imputed` |
| smoking_is_known | 0/1 | 0 if smoking_status = Unknown |
| risk_factor_count | Whole number | Count of: age≥65, HTN, heart disease, glucose≥126, BMI≥30, smoker/former |

---

## Clinical profile values

| Value | Rule |
|-------|------|
| No comorbidity | hypertension = 0 and heart_disease = 0 |
| Hypertension only | hypertension = 1 and heart_disease = 0 |
| Heart disease only | hypertension = 0 and heart_disease = 1 |
| Hypertension + Heart disease | both = 1 |

## Glucose bands (analytical labels only)

| Band | Rule |
|------|------|
| Below 70 | avg_glucose_level &lt; 70 |
| 70-99 (Normal range) | 70 ≤ x &lt; 100 |
| 100-125 (Elevated) | 100 ≤ x &lt; 126 |
| 126+ (High) | x ≥ 126 |

> Disclaimer for README/dashboard: bands are for **portfolio analytics**, not medical diagnosis or treatment advice.
