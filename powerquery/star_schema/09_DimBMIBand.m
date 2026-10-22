// Rename query to: DimBMIBand
// Depends on: StrokeRawCleaned
// Uses original bmi_band so "Missing" remains a visible category (DQ narrative).

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"bmi_band"}),
    Distinct = Table.Distinct(Kept),
    WithSort = Table.AddColumn(
        Distinct,
        "BMIBandSort",
        each
            if [bmi_band] = "Underweight" then 1
            else if [bmi_band] = "Normal" then 2
            else if [bmi_band] = "Overweight" then 3
            else if [bmi_band] = "Obese" then 4
            else if [bmi_band] = "Missing" then 5
            else 99,
        Int64.Type
    ),
    Sorted = Table.Sort(WithSort, {{"BMIBandSort", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "BMIBandKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"bmi_band", "BMIBand"}}),
    Reordered = Table.ReorderColumns(Renamed, {"BMIBandKey", "BMIBand", "BMIBandSort"})
in
    Reordered
