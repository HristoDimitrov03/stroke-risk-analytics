// Rename query to: DimGender
// Depends on: StrokeRawCleaned

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"gender"}),
    Distinct = Table.Distinct(Kept),
    Sorted = Table.Sort(Distinct, {{"gender", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "GenderKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"gender", "Gender"}}),
    Reordered = Table.ReorderColumns(Renamed, {"GenderKey", "Gender"})
in
    Reordered
