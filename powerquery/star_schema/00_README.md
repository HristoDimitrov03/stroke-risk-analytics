# Star Schema — Power Query Scripts

Scripts that build the dimensional model from `StrokeRawCleaned`:

| Order | Query | Role |
|------:|-------|------|
| 1–9 | `Dim*` | Descriptive dimensions (keys + labels + sort columns) |
| 10 | `FactStrokeAssessment` | Fact table (grain = one patient assessment) |

`StrokeRawCleaned` is the staging query and is **not loaded** to the model. Relationships are Dim (1) → Fact (*), single-direction filter. See [`docs/03_data_model.md`](../../docs/03_data_model.md).
