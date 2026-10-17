# Suncoast Health Network | Healthcare Operations Analytics

**End-to-end data analytics portfolio project** | Microsoft SQL Server · SSMS · Excel · Power Query · Power Pivot · DAX · Power BI

> **Synthetic-data disclaimer:** Suncoast Health Network is fictional. The data and findings are simulated for educational and portfolio purposes and do not describe a real healthcare system.

## Project overview

This project develops a reporting workflow to examine appointment activity, patient access, provider productivity, wait times, and billing outcomes. SQL Server stores and validates the relational data, Excel/Power Pivot supports analytical exploration, and Power BI presents five interactive reporting pages.

## Business questions

- How many appointments are completed, cancelled, or missed?
- Which departments and appointment types show higher no-show rates?
- How do wait times vary across departments?
- How do provider appointment workloads compare with completion and no-show rates?
- How do billing charges, payments, balances, claims, and denials vary by insurance?

## Data model and source tables

| Table | Rows | Role |
| --- | ---: | --- |
| `DimPatient` | 2,000 | Patient characteristics |
| `DimProvider` | 46 | Providers and specialties |
| `DimDepartment` | 8 | Departments |
| `DimInsurance` | 5 | Insurance types |
| `DimDate` | 1,096 | Date attributes |
| `FactAppointments` | 25,000 | Appointment-level activity |
| `FactBilling` | 19,604 | Billing and claims |

The supplied SQL schema defines primary keys on the ID fields and foreign-key relationships from appointments to their dimensions and from billing to appointments, patients, and insurance.

## Workflow

1. **Relational schema:** Defined dimensional and fact tables in SQL Server.
2. **CSV imports:** Used SQL Server `BULK INSERT` with header skipping (`FIRSTROW = 2`) to populate the tables.
3. **Validation:** Checked missing keys using `LEFT JOIN`, duplicate identifiers, and other quality checks.
4. **SQL analysis:** Queried appointment status, no-show patterns, departmental performance, and financial outcomes.
5. **Excel analysis:** Used Power Query, Power Pivot, and PivotTables for exploration and modeling.
6. **Power BI modeling:** Built measures, calculated columns, relationships, slicers, and interactive reports.
7. **Interactive risk analysis:** Applied a user-selectable no-show threshold alongside wait-time thresholds to categorize departments.

## Dashboard pages

| Page | Key content |
| --- | --- |
| **Executive Overview** | Appointment KPIs, monthly trends, departmental no-shows, provider summary, revenue by insurance |
| **Patient Access Analysis** | Appointment status breakdown, no-show by appointment type, wait-time distribution, departmental wait times |
| **Provider Performance** | Top providers, specialty comparison, provider matrix, workload vs no-show scatter plot |
| **Wait Time & Access Risk Lab** | Dynamic risk counts, threshold parameter, department classification and scatter plot, risk matrix |
| **Revenue Cycle Analysis** | Claims, charges, payments, balances, denial rates, insurance comparisons, paid amount by appointment month |

All five report pages are verified in the uploaded final `.pbix` and have a 1920 × 1080 report canvas.

## Selected overall KPIs

| Metric | Result |
| --- | ---: |
| Total appointments | 25,000 |
| Completed appointments | 19,604 |
| No-show appointments | 2,492 |
| No-show rate | 9.97% |
| Average wait time | 14.10 days |
| Total paid | Approximately $3.91 million |
| Total claims | 19,604 |
| Claim denial rate | 6.79% |

Numbers represent the all-period, unfiltered simulated dataset and may be displayed with rounding in report visuals.

## Reporting conventions and model caveats

- **Appointment-year attribution:** Measures using `USERELATIONSHIP` associate billing amounts with the *appointment date*. The report's “Paid Amount by Appointment Month” should therefore not be described as a cash-receipt / payment-date trend.
- **Relationship ambiguity:** The Power BI model uses an inactive appointment–billing relationship for some calculations; date/department effects on financial measures must be explicitly tested.
- **Risk scoring:** The High/Medium/Low department classification is a **custom operational heuristic**, not a validated clinical risk score.
- **Provider identity:** Use `ProviderID` (or a unique provider display label) in comparisons where duplicate provider names could cause accidental grouping.

## Repository contents

```text
suncoast-health-analytics/
├── README.md
├── sql/
│   ├── 01_Create_Database_and_Tables.sql
│   ├── 02_Bulk_Insert_Data.sql
│   ├── 03_Data_Validation.sql
│   └── 04_Business_Analysis.sql
├── excel/
│   └── Suncoast_Health_Analytics_PowerPivot_Report.xlsx
├── powerbi/
│   └── Suncoast_Health_Network_Analytics_Final.pbix
├── screenshots/
│   ├── 01_executive_overview.png
│   ├── 02_patient_access.png
│   ├── 03_provider_performance.png
│   ├── 04_access_risk_lab.png
│   └── 05_revenue_cycle.png
└── docs/
    ├── data_dictionary.md
    ├── methodology.md
    └── dax_measures.md
```

## Reproducibility notes

The import script currently points to a local Windows directory (`C:\SuncoastHealthDatasets`), which other users will need to replace. The supplied schema script starts with `USE SuncoastHealthAnalytics` rather than creating the database; a fresh setup requires creating the database first. The schema also contains a trailing comma after `PatientSegment VARCHAR(50)` that should be fixed in a publish-ready script. The original source CSVs are not included in the current upload and are needed for complete re-execution.

## Next steps before publishing

- Export verified, clean full-page screenshots from Power BI.
- Review SQL scripts for a reproducible run order and remove redundant queries.
- Export and review DAX measures and relationship details using Power BI tools.
- Confirm that every slicer affects the intended fact tables.
- Check `.pbix` connection settings and repository files for personal/local paths before publishing.

## Publication status and verification boundary

This repository contains the supplied PBIX and Excel workbooks plus cleaned, publication-ready SQL scripts and documented assumptions. Raw CSV inputs and reproducible Power Query step exports are not included; restoring the complete source workflow requires those inputs. DAX documented in `docs/dax_measures.md` is reconstructed from development notes and should be confirmed against the Desktop model before publication.

The `screenshots/` directory is reserved for clean exported report pages; draft Power BI editing screenshots should not be presented as official exports.
