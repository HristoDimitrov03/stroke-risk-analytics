# Data Model — Star Schema

## Pattern

- **Staging:** `StrokeRawCleaned` (Power Query only; not loaded to the model)  
- **Fact:** `FactStrokeAssessment` (grain = one patient assessment)  
- **Dimensions:** 9 descriptive tables related by surrogate keys  

## Relationship map

| Dimension | Key | Fact column |
|-----------|-----|-------------|
| DimGender | GenderKey | GenderKey |
| DimAgeBand | AgeBandKey | AgeBandKey |
| DimMaritalStatus | MaritalStatusKey | MaritalStatusKey |
| DimWorkType | WorkTypeKey | WorkTypeKey |
| DimResidence | ResidenceKey | ResidenceKey |
| DimSmokingStatus | SmokingStatusKey | SmokingStatusKey |
| DimClinicalProfile | ClinicalProfileKey | ClinicalProfileKey |
| DimGlucoseBand | GlucoseBandKey | GlucoseBandKey |
| DimBMIBand | BMIBandKey | BMIBandKey |

All relationships: **1:* (Dim → Fact)**, single-direction filter.

## Fact measures / flags (columns)

| Column | Role |
|--------|------|
| PatientID | Degenerate business key |
| Age, AgeYears | Age facts |
| AvgGlucoseLevel, BMI, BMIImputed | Clinical measurements |
| BMIIsMissing, BMIIsImputed | Data-quality flags |
| HypertensionFlag, HeartDiseaseFlag | Additive clinical flags |
| StrokeFlag | Outcome (0/1) |
| RiskFactorCount | Precomputed helper for cumulative risk |
| IsPediatric | Helper flag |

## Notes

- No Date dimension (source has no event dates).  
- `DimBMIBand` uses original BMI band including **Missing** (supports DQ narrative).  
- Sort columns exist on band/profile dims for correct visual axis order.
