// Rename query to: DimWorkType
// Depends on: StrokeRawCleaned

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"work_type_clean"}),
    Distinct = Table.Distinct(Kept),
    Sorted = Table.Sort(Distinct, {{"work_type_clean", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "WorkTypeKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(WithKey, {{"work_type_clean", "WorkType"}}),
    Reordered = Table.ReorderColumns(Renamed, {"WorkTypeKey", "WorkType"})
in
    Reordered
