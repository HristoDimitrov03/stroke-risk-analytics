// Rename query to: DimSmokingStatus
// Depends on: StrokeRawCleaned
// Sort order for slicers: Smokes → Formerly smoked → Never smoked → Unknown

let
    Source = StrokeRawCleaned,
    Kept = Table.SelectColumns(Source, {"smoking_status", "smoking_is_known"}),
    Distinct = Table.Distinct(Kept),
    WithSort = Table.AddColumn(
        Distinct,
        "SmokingStatusSort",
        each
            if [smoking_status] = "Smokes" then 1
            else if [smoking_status] = "Formerly smoked" then 2
            else if [smoking_status] = "Never smoked" then 3
            else if [smoking_status] = "Unknown" then 4
            else 99,
        Int64.Type
    ),
    Sorted = Table.Sort(WithSort, {{"SmokingStatusSort", Order.Ascending}}),
    WithKey = Table.AddIndexColumn(Sorted, "SmokingStatusKey", 1, 1, Int64.Type),
    Renamed = Table.RenameColumns(
        WithKey,
        {
            {"smoking_status", "SmokingStatus"},
            {"smoking_is_known", "SmokingIsKnown"}
        }
    ),
    Reordered = Table.ReorderColumns(
        Renamed,
        {"SmokingStatusKey", "SmokingStatus", "SmokingIsKnown", "SmokingStatusSort"}
    )
in
    Reordered
