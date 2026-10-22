// Rename query to: DimAgeBand
// Depends on: StrokeRawCleaned

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"age_band"}),
    Distinct = Table.Distinct(Kept),
    WithSort = Table.AddColumn(
        Distinct,
        "AgeBandSort",
        each
            if [age_band] = "0-17" then 1
            else if [age_band] = "18-39" then 2
            else if [age_band] = "40-54" then 3
            else if [age_band] = "55-64" then 4
            else if [age_band] = "65-74" then 5
            else if [age_band] = "75+" then 6
            else 99,
        Int64.Type
    ),
    Sorted = Table.Sort(WithSort, {{"AgeBandSort", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "AgeBandKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"age_band", "AgeBand"}}),
    Reordered = Table.ReorderColumns(Renamed, {"AgeBandKey", "AgeBand", "AgeBandSort"})
in
    Reordered
