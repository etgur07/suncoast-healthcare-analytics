# Methodology & reproducibility

## 1. Source and context

Synthetic operational dataset representing a fictional healthcare network, with an analytical reporting window of 2023–2025. Counts and selected overall KPIs were compared against the accompanying workbook and report discussions. These are **not real-world healthcare findings**.

## 2. SQL Server

Run scripts in `sql/` numerically. The setup script now creates the database (if absent), fixes a trailing comma in `DimPatient`, and creates tables with declared PK/FK constraints. The bulk import script reads CSVs from a local Windows directory that must be configured for each SQL Server installation; SQL Server must have filesystem permissions. Original CSV files were not supplied, so full reproducibility requires obtaining/regenerating the synthetic dataset.

The validation script contains missing-reference checks, duplicate-key-group checks, missing-value checks and table counts. **The scripts contain queries, not archived execution output**. Do not claim every check returned zero without rerunning.

The business-analysis script performs appointment KPIs, no-show rates, monthly trends, revenue aggregation, claim distributions, insurance denial rates, wait times, provider analysis and department summary. Publication adjustments: removed duplicate last query and grouped provider metrics using `ProviderID`.

## 3. Excel, Power Query and Power Pivot

The supplied `Suncoast_Health_Analytics_PowerPivot_Report.xlsx` is the Excel analysis artifact. During development, SQL tables were connected through Power Query and modeled/analyzed using Power Pivot and PivotTables. Individual applied-step history and every measure should be verified directly in Excel before claiming exact transformations or exporting reusable scripts.

## 4. Power BI

Five finalized report pages: Executive Overview; Patient Access Analysis; Provider Performance; Wait Time & Access Risk Lab; Revenue Cycle Analysis. All pages use 1920×1080 canvas. Measures and calculated-column definitions in `dax_measures.md` are **reconstructed from the development conversation** and should be verified in Power BI, not represented as a full automatic export from the PBIX binary.

### Billing date attribution

`USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID])` is used in appointment-attributed financial measures. These totals answer **how much was paid for appointments occurring in a selected month/year**, not **how much cash was received during that month/year**. The separate `FactBilling[PaymentDate]` supports a payment-date analysis but is not interchangeable.

### Risk heuristics

The adjustable high-risk no-show threshold combines with a fixed 18-day high wait-time trigger. Medium is classified with an 8% no-show or 14-day average wait-time floor. Low contains active departments matching neither category. This is an **illustrative operational rule**, not a clinically validated scoring method.

## 5. Quality-control checklist before publication

- Compare source table counts and missing-key tests with a fresh SQL run.
- Check whether `DimProvider[ProviderName]` duplicates exist; use `ProviderID` in provider-level grain.
- Verify all published DAX definitions, data types and formatted percentages in the actual `.pbix`.
- Test 2024 year filter on appointment AND billing KPIs, including different departments and insurance values.
- Verify the date semantics of the monthly paid-amount visualization.
- Review the PBIX connection configuration for local server names, credentials or workspace-specific metadata.
- Export uncluttered full-page screenshots after clearing selections.
