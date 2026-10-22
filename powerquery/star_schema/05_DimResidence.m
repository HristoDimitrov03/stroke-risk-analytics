// Rename query to: DimResidence
// Depends on: StrokeRawCleaned

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"residence_type"}),
    Distinct = Table.Distinct(Kept),
    Sorted = Table.Sort(Distinct, {{"residence_type", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "ResidenceKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"residence_type", "ResidenceType"}}),
    Reordered = Table.ReorderColumns(Renamed, {"ResidenceKey", "ResidenceType"})
in
    Reordered
