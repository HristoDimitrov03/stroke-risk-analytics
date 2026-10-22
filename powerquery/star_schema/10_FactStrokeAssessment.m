// Rename query to: FactStrokeAssessment
// Depends on: StrokeRawCleaned + ALL Dim* queries
// Create this query LAST.

let
    Source = StrokeRawCleaned,

    // ---- Lookup surrogate keys from each dimension ----
    JoinGender = Table.NestedJoin(
        Source, {"gender"},
        DimGender, {"Gender"},
        "jGender", JoinKind.LeftOuter
    ),
    ExpandGender = Table.ExpandTableColumn(JoinGender, "jGender", {"GenderKey"}, {"GenderKey"}),

    JoinAgeBand = Table.NestedJoin(
        ExpandGender, {"age_band"},
        DimAgeBand, {"AgeBand"},
        "jAge", JoinKind.LeftOuter
    ),
    ExpandAgeBand = Table.ExpandTableColumn(JoinAgeBand, "jAge", {"AgeBandKey"}, {"AgeBandKey"}),

    JoinMarital = Table.NestedJoin(
        ExpandAgeBand, {"ever_married"},
        DimMaritalStatus, {"MaritalStatus"},
        "jMarital", JoinKind.LeftOuter
    ),
    ExpandMarital = Table.ExpandTableColumn(JoinMarital, "jMarital", {"MaritalStatusKey"}, {"MaritalStatusKey"}),

    JoinWork = Table.NestedJoin(
        ExpandMarital, {"work_type_clean"},
        DimWorkType, {"WorkType"},
        "jWork", JoinKind.LeftOuter
    ),
    ExpandWork = Table.ExpandTableColumn(JoinWork, "jWork", {"WorkTypeKey"}, {"WorkTypeKey"}),

    JoinResidence = Table.NestedJoin(
        ExpandWork, {"residence_type"},
        DimResidence, {"ResidenceType"},
        "jRes", JoinKind.LeftOuter
    ),
    ExpandResidence = Table.ExpandTableColumn(JoinResidence, "jRes", {"ResidenceKey"}, {"ResidenceKey"}),

    JoinSmoking = Table.NestedJoin(
        ExpandResidence, {"smoking_status"},
        DimSmokingStatus, {"SmokingStatus"},
        "jSmoke", JoinKind.LeftOuter
    ),
    ExpandSmoking = Table.ExpandTableColumn(JoinSmoking, "jSmoke", {"SmokingStatusKey"}, {"SmokingStatusKey"}),

    JoinClinical = Table.NestedJoin(
        ExpandSmoking, {"clinical_profile"},
        DimClinicalProfile, {"ClinicalProfile"},
        "jClin", JoinKind.LeftOuter
    ),
    ExpandClinical = Table.ExpandTableColumn(JoinClinical, "jClin", {"ClinicalProfileKey"}, {"ClinicalProfileKey"}),

    JoinGlucose = Table.NestedJoin(
        ExpandClinical, {"glucose_band"},
        DimGlucoseBand, {"GlucoseBand"},
        "jGlu", JoinKind.LeftOuter
    ),
    ExpandGlucose = Table.ExpandTableColumn(JoinGlucose, "jGlu", {"GlucoseBandKey"}, {"GlucoseBandKey"}),

    JoinBMI = Table.NestedJoin(
        ExpandGlucose, {"bmi_band"},
        DimBMIBand, {"BMIBand"},
        "jBMI", JoinKind.LeftOuter
    ),
    ExpandBMI = Table.ExpandTableColumn(JoinBMI, "jBMI", {"BMIBandKey"}, {"BMIBandKey"}),

    // ---- Keep fact grain columns only (keys + measures/flags) ----
    Selected = Table.SelectColumns(
        ExpandBMI,
        {
            "patient_id",
            "GenderKey",
            "AgeBandKey",
            "MaritalStatusKey",
            "WorkTypeKey",
            "ResidenceKey",
            "SmokingStatusKey",
            "ClinicalProfileKey",
            "GlucoseBandKey",
            "BMIBandKey",
            "age",
            "age_years",
            "avg_glucose_level",
            "bmi",
            "bmi_imputed",
            "bmi_is_missing",
            "bmi_is_imputed",
            "is_pediatric",
            "hypertension",
            "heart_disease",
            "stroke",
            "risk_factor_count"
        }
    ),

    Renamed = Table.RenameColumns(
        Selected,
        {
            {"patient_id", "PatientID"},
            {"age", "Age"},
            {"age_years", "AgeYears"},
            {"avg_glucose_level", "AvgGlucoseLevel"},
            {"bmi", "BMI"},
            {"bmi_imputed", "BMIImputed"},
            {"bmi_is_missing", "BMIIsMissing"},
            {"bmi_is_imputed", "BMIIsImputed"},
            {"is_pediatric", "IsPediatric"},
            {"hypertension", "HypertensionFlag"},
            {"heart_disease", "HeartDiseaseFlag"},
            {"stroke", "StrokeFlag"},
            {"risk_factor_count", "RiskFactorCount"}
        }
    ),

    Typed = Table.TransformColumnTypes(
        Renamed,
        {
            {"PatientID", Int64.Type},
            {"GenderKey", Int64.Type},
            {"AgeBandKey", Int64.Type},
            {"MaritalStatusKey", Int64.Type},
            {"WorkTypeKey", Int64.Type},
            {"ResidenceKey", Int64.Type},
            {"SmokingStatusKey", Int64.Type},
            {"ClinicalProfileKey", Int64.Type},
            {"GlucoseBandKey", Int64.Type},
            {"BMIBandKey", Int64.Type},
            {"Age", type number},
            {"AgeYears", Int64.Type},
            {"AvgGlucoseLevel", type number},
            {"BMI", type number},
            {"BMIImputed", type number},
            {"BMIIsMissing", Int64.Type},
            {"BMIIsImputed", Int64.Type},
            {"IsPediatric", Int64.Type},
            {"HypertensionFlag", Int64.Type},
            {"HeartDiseaseFlag", Int64.Type},
            {"StrokeFlag", Int64.Type},
            {"RiskFactorCount", Int64.Type}
        }
    )
in
    Typed
