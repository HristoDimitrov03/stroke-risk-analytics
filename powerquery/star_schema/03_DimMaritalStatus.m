// Rename query to: DimMaritalStatus
// Depends on: StrokeRawCleaned

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"ever_married"}),
    Distinct = Table.Distinct(Kept),
    Sorted = Table.Sort(Distinct, {{"ever_married", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "MaritalStatusKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"ever_married", "MaritalStatus"}}),
    Reordered = Table.ReorderColumns(Renamed, {"MaritalStatusKey", "MaritalStatus"})
in
    Reordered
