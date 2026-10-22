// Rename query to: DimClinicalProfile
// Depends on: StrokeRawCleaned

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"clinical_profile"}),
    Distinct = Table.Distinct(Kept),
    WithSort = Table.AddColumn(
        Distinct,
        "ClinicalProfileSort",
        each
            if [clinical_profile] = "No comorbidity" then 1
            else if [clinical_profile] = "Hypertension only" then 2
            else if [clinical_profile] = "Heart disease only" then 3
            else if [clinical_profile] = "Hypertension + Heart disease" then 4
            else 99,
        Int64.Type
    ),
    // Helpful attributes for tooltips / legends
    WithFlags = Table.AddColumn(
        WithSort,
        "HasHypertension",
        each if Text.Contains([clinical_profile], "Hypertension") then "Yes" else "No",
        type text
    ),
    WithFlags2 = Table.AddColumn(
        WithFlags,
        "HasHeartDisease",
        each if Text.Contains([clinical_profile], "Heart disease") then "Yes" else "No",
        type text
    ),
    Sorted = Table.Sort(WithFlags2, {{"ClinicalProfileSort", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "ClinicalProfileKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"clinical_profile", "ClinicalProfile"}}),
    Reordered = Table.ReorderColumns(
        Renamed,
        {
            "ClinicalProfileKey", "ClinicalProfile", "HasHypertension",
            "HasHeartDisease", "ClinicalProfileSort"
        }
    )
in
    Reordered
