// =============================================================================
// PROJECT : Stroke Risk Analytics (Portfolio)
// SPRINT  : 1 — Data cleaning in Power Query
// QUERY   : Rename to "StrokeRawCleaned" after pasting
//
// HOW TO USE
// 1. Power BI Desktop → Home → Transform data
// 2. New Source → Blank Query
// 3. Home → Advanced Editor
// 4. Delete the default code
// 5. Paste THIS entire file
// 6. If needed, edit FilePath below
// 7. Click Done → rename query → Close & Apply
//
// WHAT THIS SCRIPT DOES (high level)
// - Loads the raw Kaggle CSV
// - Sets correct data types
// - Renames inconsistent columns
// - Flags missing BMI (does NOT delete those patients)
// - Imputes BMI using median by age_band + gender
// - Adds Yes/No labels, age/BMI/glucose bands, comorbidity profile
// - Adds a simple risk_factor_count for later DAX / visuals
// =============================================================================

let
    // -------------------------------------------------------------------------
    // 1) SOURCE PATH
    // Change this only if you moved the project folder on your PC.
    // -------------------------------------------------------------------------
    FilePath = "C:\Users\hrist\Desktop\W\Cursor_Projects\stroke_prediction\data\raw\healthcare-dataset-stroke-data.csv",

    // -------------------------------------------------------------------------
    // 2) LOAD CSV
    // Encoding 65001 = UTF-8 (avoids strange characters)
    // -------------------------------------------------------------------------
    Source = Csv.Document(
        File.Contents(FilePath),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),

    // First row contains column names like id, gender, age, ...
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // -------------------------------------------------------------------------
    // 3) REPLACE "N/A" IN BMI BEFORE NUMBER CONVERSION
    // The Kaggle file stores missing BMI as the TEXT "N/A" (201 rows),
    // not as empty cells. Power Query cannot convert "N/A" to a number,
    // which caused: DataFormat.Error: We couldn't convert to Number.
    // Fix: turn "N/A" into a real null, THEN set the column type to number.
    // -------------------------------------------------------------------------
    ReplacedBmiNA = Table.ReplaceValue(
        PromotedHeaders,
        "N/A",
        null,
        Replacer.ReplaceValue,
        {"bmi"}
    ),

    // -------------------------------------------------------------------------
    // 4) DATA TYPES
    // Wrong types break filters, relationships, and DAX later.
    // -------------------------------------------------------------------------
    Typed = Table.TransformColumnTypes(
        ReplacedBmiNA,
        {
            {"id", Int64.Type},
            {"gender", type text},
            {"age", type number},
            {"hypertension", Int64.Type},
            {"heart_disease", Int64.Type},
            {"ever_married", type text},
            {"work_type", type text},
            {"Residence_type", type text},
            {"avg_glucose_level", type number},
            {"bmi", type number},
            {"smoking_status", type text},
            {"stroke", Int64.Type}
        }
    ),

    // -------------------------------------------------------------------------
    // 4) CLEAN COLUMN NAMES
    // id → patient_id (clearer grain)
    // Residence_type → residence_type (consistent naming)
    // -------------------------------------------------------------------------
    Renamed = Table.RenameColumns(
        Typed,
        {
            {"id", "patient_id"},
            {"Residence_type", "residence_type"}
        }
    ),

    // -------------------------------------------------------------------------
    // 4b) SMOKING STATUS DISPLAY LABELS
    // Capitalize first word for slicers/charts (Unknown already correct).
    // -------------------------------------------------------------------------
    SmokingLabels = Table.ReplaceValue(
        Table.ReplaceValue(
            Table.ReplaceValue(
                Renamed,
                "never smoked",
                "Never smoked",
                Replacer.ReplaceValue,
                {"smoking_status"}
            ),
            "formerly smoked",
            "Formerly smoked",
            Replacer.ReplaceValue,
            {"smoking_status"}
        ),
        "smokes",
        "Smokes",
        Replacer.ReplaceValue,
        {"smoking_status"}
    ),

    // -------------------------------------------------------------------------
    // 5) BMI MISSING FLAG
    // Critical decision: we KEEP rows with missing BMI.
    // Why? Stroke rate is much higher when BMI is missing (~19.9% vs ~4.3%).
    // Dropping them would bias the analysis.
    // -------------------------------------------------------------------------
    AddBmiMissing = Table.AddColumn(
        SmokingLabels,
        "bmi_is_missing",
        each if [bmi] = null then 1 else 0,
        Int64.Type
    ),

    // Whole years (useful for display); original age kept for infants (0.08 etc.)
    AddAgeYears = Table.AddColumn(
        AddBmiMissing,
        "age_years",
        each Number.RoundDown([age]),
        Int64.Type
    ),

    // Age bands = dimension-ready groups for charts and DimAgeBand
    AddAgeBand = Table.AddColumn(
        AddAgeYears,
        "age_band",
        each
            if [age] < 18 then "0-17"
            else if [age] < 40 then "18-39"
            else if [age] < 55 then "40-54"
            else if [age] < 65 then "55-64"
            else if [age] < 75 then "65-74"
            else "75+",
        type text
    ),

    AddIsPediatric = Table.AddColumn(
        AddAgeBand,
        "is_pediatric",
        each if [age] < 18 then 1 else 0,
        Int64.Type
    ),

    // -------------------------------------------------------------------------
    // 6) WORK TYPE CLEANUP
    // "children" is not a job — relabel for clearer dashboards.
    // -------------------------------------------------------------------------
    AddWorkTypeClean = Table.AddColumn(
        AddIsPediatric,
        "work_type_clean",
        each
            if [work_type] = "children" then "Child / Not in workforce"
            else if [work_type] = "Govt_job" then "Government job"
            else if [work_type] = "Never_worked" then "Never worked"
            else [work_type],
        type text
    ),

    // -------------------------------------------------------------------------
    // 7) FRIENDLY YES/NO LABELS
    // Keep numeric 0/1 for measures; labels for slicers/legends.
    // -------------------------------------------------------------------------
    AddHypertensionLabel = Table.AddColumn(
        AddWorkTypeClean,
        "hypertension_label",
        each if [hypertension] = 1 then "Yes" else "No",
        type text
    ),

    AddHeartDiseaseLabel = Table.AddColumn(
        AddHypertensionLabel,
        "heart_disease_label",
        each if [heart_disease] = 1 then "Yes" else "No",
        type text
    ),

    AddStrokeLabel = Table.AddColumn(
        AddHeartDiseaseLabel,
        "stroke_label",
        each if [stroke] = 1 then "Yes" else "No",
        type text
    ),

    // -------------------------------------------------------------------------
    // 8) CLINICAL PROFILE (comorbidity dimension seed)
    // Combines hypertension × heart disease into one analytical attribute.
    // -------------------------------------------------------------------------
    AddClinicalProfile = Table.AddColumn(
        AddStrokeLabel,
        "clinical_profile",
        each
            if [hypertension] = 0 and [heart_disease] = 0 then "No comorbidity"
            else if [hypertension] = 1 and [heart_disease] = 0 then "Hypertension only"
            else if [hypertension] = 0 and [heart_disease] = 1 then "Heart disease only"
            else "Hypertension + Heart disease",
        type text
    ),

    // -------------------------------------------------------------------------
    // 9) GLUCOSE BANDS
    // Analytical buckets only — NOT a medical diagnosis.
    // -------------------------------------------------------------------------
    AddGlucoseBand = Table.AddColumn(
        AddClinicalProfile,
        "glucose_band",
        each
            if [avg_glucose_level] < 70 then "Below 70"
            else if [avg_glucose_level] < 100 then "70-99 (Normal range)"
            else if [avg_glucose_level] < 126 then "100-125 (Elevated)"
            else "126+ (High)",
        type text
    ),

    // BMI band from ORIGINAL bmi (Missing stays visible as its own category)
    AddBmiBand = Table.AddColumn(
        AddGlucoseBand,
        "bmi_band",
        each
            if [bmi] = null then "Missing"
            else if [bmi] < 18.5 then "Underweight"
            else if [bmi] < 25 then "Normal"
            else if [bmi] < 30 then "Overweight"
            else "Obese",
        type text
    ),

    // -------------------------------------------------------------------------
    // 10) BMI IMPUTATION (transparent)
    // Method: median BMI within each age_band × gender group.
    // We keep original bmi AND mark rows we filled (bmi_is_imputed).
    // -------------------------------------------------------------------------
    MedianLookup = Table.Group(
        Table.SelectRows(AddBmiBand, each [bmi] <> null),
        {"age_band", "gender"},
        {{"median_bmi", each List.Median([bmi]), type number}}
    ),

    JoinedMedian = Table.NestedJoin(
        AddBmiBand,
        {"age_band", "gender"},
        MedianLookup,
        {"age_band", "gender"},
        "MedianJoin",
        JoinKind.LeftOuter
    ),

    ExpandedMedian = Table.ExpandTableColumn(
        JoinedMedian,
        "MedianJoin",
        {"median_bmi"},
        {"median_bmi"}
    ),

    OverallMedian = List.Median(Table.SelectRows(AddBmiBand, each [bmi] <> null)[bmi]),

    AddBmiImputed = Table.AddColumn(
        ExpandedMedian,
        "bmi_imputed",
        each
            if [bmi] <> null then [bmi]
            else if [median_bmi] <> null then Number.Round([median_bmi], 1)
            else Number.Round(OverallMedian, 1),
        type number
    ),

    AddBmiIsImputed = Table.AddColumn(
        AddBmiImputed,
        "bmi_is_imputed",
        each if [bmi] = null then 1 else 0,
        Int64.Type
    ),

    // Band using imputed BMI (so charts that need complete BMI categories can work)
    AddBmiBandImputed = Table.AddColumn(
        AddBmiIsImputed,
        "bmi_band_imputed",
        each
            if [bmi_imputed] < 18.5 then "Underweight"
            else if [bmi_imputed] < 25 then "Normal"
            else if [bmi_imputed] < 30 then "Overweight"
            else "Obese",
        type text
    ),

    // Unknown smoking stays as "Unknown"; this flag helps filter "known only" analyses
    AddSmokingKnown = Table.AddColumn(
        AddBmiBandImputed,
        "smoking_is_known",
        each if [smoking_status] = "Unknown" then 0 else 1,
        Int64.Type
    ),

    // -------------------------------------------------------------------------
    // 11) SIMPLE RISK FACTOR COUNT
    // Used later for "cumulative risk" visuals / DAX.
    // Factors counted:
    //   age >= 65, hypertension, heart disease, glucose >= 126,
    //   BMI >= 30, currently Smokes OR Formerly smoked
    // -------------------------------------------------------------------------
    AddRiskFactorCount = Table.AddColumn(
        AddSmokingKnown,
        "risk_factor_count",
        each
            (if [age] >= 65 then 1 else 0)
            + [hypertension]
            + [heart_disease]
            + (if [avg_glucose_level] >= 126 then 1 else 0)
            + (if [bmi_imputed] >= 30 then 1 else 0)
            + (if List.Contains({"Smokes", "Formerly smoked"}, [smoking_status]) then 1 else 0),
        Int64.Type
    ),

    // Remove helper column from the median join
    RemovedHelper = Table.RemoveColumns(AddRiskFactorCount, {"median_bmi"}),

    // Final column order = easier to screenshot and explain
    Reordered = Table.ReorderColumns(
        RemovedHelper,
        {
            "patient_id", "gender", "age", "age_years", "age_band", "is_pediatric",
            "hypertension", "hypertension_label", "heart_disease", "heart_disease_label",
            "clinical_profile", "ever_married", "work_type", "work_type_clean",
            "residence_type", "avg_glucose_level", "glucose_band",
            "bmi", "bmi_imputed", "bmi_is_missing", "bmi_is_imputed", "bmi_band", "bmi_band_imputed",
            "smoking_status", "smoking_is_known", "stroke", "stroke_label", "risk_factor_count"
        }
    )
in
    Reordered
