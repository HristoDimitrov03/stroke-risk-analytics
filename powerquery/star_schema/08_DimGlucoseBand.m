// Rename query to: DimGlucoseBand
// Depends on: StrokeRawCleaned
// Note: bands are analytical labels, not medical diagnoses.

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"glucose_band"}),
    Distinct = Table.Distinct(Kept),
    WithSort = Table.AddColumn(
        Distinct,
        "GlucoseBandSort",
        each
            if [glucose_band] = "Below 70" then 1
            else if [glucose_band] = "70-99 (Normal range)" then 2
            else if [glucose_band] = "100-125 (Elevated)" then 3
            else if [glucose_band] = "126+ (High)" then 4
            else 99,
        Int64.Type
    ),
    Sorted = Table.Sort(WithSort, {{"GlucoseBandSort", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "GlucoseBandKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"glucose_band", "GlucoseBand"}}),
    Reordered = Table.ReorderColumns(Renamed, {"GlucoseBandKey", "GlucoseBand", "GlucoseBandSort"})
in
    Reordered
