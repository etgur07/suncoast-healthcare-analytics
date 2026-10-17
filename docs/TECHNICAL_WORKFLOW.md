# Suncoast Health Network — Technical Workflow

**End-to-end simulated healthcare analytics portfolio project**  
**Stack:** Microsoft SQL Server, SSMS, Excel, Power Query, Power Pivot, DAX, Power BI Desktop  
**Reporting period:** 2023–2025  
**Data disclaimer:** Fictional network and simulated operational data; not real patient or provider records.

## 1. Project objective

Build an end-to-end analytical workflow to explore appointment completion, no-shows, wait time, provider workload, insurance claims, payments, and department-level operational risk. The final report contains five interactive Power BI pages. The project demonstrates a reproducible *process*, while full reproducibility requires the original simulated CSV input files, which are not included in the provided uploads.

## 2. Source files and their roles

| File | Purpose |
|---|---|
| `sql/01_Create_Database_and_Tables.sql` | Defines five dimension tables and two fact tables, keys and foreign keys |
| `sql/02_Bulk_Insert_Data.sql` | Loads seven CSV files using `BULK INSERT` and checks counts |
| `sql/03_Data_Validation.sql` | Checks referential gaps, duplicate IDs, selected null fields and row counts |
| `sql/04_Business_Analysis.sql` | Runs appointment, revenue, insurance, provider and department aggregate queries |
| `excel/Suncoast_Health_Analytics_PowerPivot_Report.xlsx` | Spreadsheet-based analysis deliverable |
| `powerbi/Suncoast_Health_Network_Analytics_Final.pbix` | Interactive report deliverable |
| `screenshots/` | Five report-page image exports |

## 3. SQL Server: schema design

The submitted schema uses dimension and fact tables:

| Table | Grain or purpose | Primary key | Relevant fields |
|---|---|---|---|
| `DimPatient` | One record per patient | `PatientID` | Age, Gender, Zipcode, PatientSegment |
| `DimProvider` | One record per provider ID | `ProviderID` | ProviderName, Specialty |
| `DimDepartment` | One record per department | `DepartmentID` | DepartmentName |
| `DimInsurance` | One record per insurance ID | `InsuranceID` | InsuranceType |
| `DimDate` | One record per calendar date ID | `DateID` | FullDate, Year, Quarter, Month, MonthName |
| `FactAppointments` | One record per appointment | `AppointmentID` | PatientID, ProviderID, DepartmentID, DateID, AppointmentStatus, AppointmentType, WaitTimeDays, VisitDurationMinutes |
| `FactBilling` | One record per billing record | `BillingID` | AppointmentID, PatientID, InsuranceID, ChargeAmount, PaidAmount, AdjustmentAmount, BalanceAmount, ClaimStatus, PaymentDate |

**SQL foreign keys:** `FactAppointments` references Patient, Provider, Department and Date dimensions. `FactBilling` references the appointment, patient and insurance tables. The two fact tables are connected through `AppointmentID` in the SQL schema.

**Important setup caveat:** The supplied `01_Create_Database_and_Tables.sql` begins with `USE SuncoastHealthAnalytics;` rather than a `CREATE DATABASE` command. It also contains a trailing comma after `DimPatient.PatientSegment`, which must be corrected before running that script from scratch. The uploaded script is documented here as received; this guide does not claim it executes unmodified against a blank server.

## 4. Data ingestion with T-SQL

The bulk-loading script uses SQL Server `BULK INSERT` to read the following files from `C:\SuncoastHealthDatasets\`:

1. `DimPatient.csv`
2. `DimProvider.csv`
3. `DimDepartment.csv`
4. `DimInsurance.csv`
5. `DimDate.csv`
6. `FactAppointments.csv`
7. `FactBilling.csv`

A representative statement from the submitted workflow:

```sql
BULK INSERT DimProvider
FROM 'C:\SuncoastHealthDatasets\DimProvider.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);
```

**Dependency order:** Load dimensions before appointment facts, then billing facts, to respect the SQL foreign-key constraints. The script performs count checks after several imports.

**Portability note:** The Windows file path and SQL Server permissions are environment-specific. Each CSV must be made available to the SQL Server service account, not just the client computer.

## 5. SQL quality validation

`03_Data_Validation.sql` includes four types of checks:

- **Referential integrity:** LEFT JOIN anti-matches for missing referenced patient, provider, department, date, appointment and insurance IDs.
- **Primary-key uniqueness:** `GROUP BY ... HAVING COUNT(*) > 1` on patient, provider, department, insurance, appointment and billing IDs.
- **Missing required analytical fields:** NULL tests for appointment status/type, appointment patient ID, charge amount, paid amount and claim status.
- **Dataset completeness:** `COUNT(*)` across the seven source tables.

The uploaded script provides validation *queries*, not a saved result set. Specific pass/fail counts must be confirmed from SQL execution output rather than inferred from the script alone. The script contains repeated row-count query text toward the end.

### Dataset counts represented in the completed project

| Table | Rows |
|---|---:|
| DimPatient | 2,000 |
| DimProvider | 46 |
| DimDepartment | 8 |
| DimInsurance | 5 |
| DimDate | 1,096 |
| FactAppointments | 25,000 |
| FactBilling | 19,604 |

These project counts are consistent with the developed report and earlier import checks; keep a timestamped query-result export if independent verification is required.

## 6. Business analysis in SQL

`04_Business_Analysis.sql` contains queries for:

1. Network-wide appointment counts, status counts, no-show rate and average wait time.
2. Department no-show rates.
3. Monthly appointment trends by year and month.
4. Billing totals, adjustments, balances and denial rate.
5. Revenue by insurance category.
6. Claim status mix.
7. Denial rate by insurance.
8. Average wait time by department.
9. Provider appointment performance.
10. Department performance combining appointments and billing.

The tenth department summary query appears twice in the submitted file. A cleaned publication version should remove the duplicate without changing the reported business logic.

### Selected SQL patterns

```sql
-- Network no-show percentage
SELECT
    COUNT(*) AS TotalAppointments,
    SUM(CASE WHEN AppointmentStatus = 'No Show' THEN 1 ELSE 0 END)
        AS NoShowAppointments,
    CAST(
        100.0 * SUM(CASE WHEN AppointmentStatus = 'No Show' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS NoShowRatePercent
FROM FactAppointments;
```

```sql
-- Insurance denial rates
SELECT
    i.InsuranceType,
    COUNT(*) AS TotalClaims,
    SUM(CASE WHEN b.ClaimStatus = 'Denied' THEN 1 ELSE 0 END) AS DeniedClaims,
    CAST(
        100.0 * SUM(CASE WHEN b.ClaimStatus = 'Denied' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS DenialRatePercent
FROM FactBilling b
JOIN DimInsurance i ON i.InsuranceID = b.InsuranceID
GROUP BY i.InsuranceType;
```

**Provider grain caution:** The submitted provider analysis groups by `ProviderName` and `Specialty`; distinct IDs with identical names/specialties could be aggregated together. Group by `ProviderID`, or use a unique provider label, when verifying provider-level calculations.

**Visit-duration caution:** The submitted SQL provider query averages `VisitDurationMinutes` without filtering appointment status; the Power BI measure developed in the project excludes noncompleted appointments and nonpositive durations. These definitions should not be treated as interchangeable.

**One-to-many caution:** The department summary LEFT JOIN to billing assumes no unexpected multiplication of appointment rows. Validate the actual `AppointmentID` cardinality before treating appointment counts after this join as unique counts.

## 7. Excel, Power Query and Power Pivot

The workflow used Excel as an intermediate analytical and modeling environment before Power BI:

- Connected Excel/Power Query to the SQL Server database.
- Loaded dimension and fact tables and prepared query outputs.
- Organized relationships in Power Pivot and used DAX measures/PivotTables for analytical review.
- Produced `Suncoast_Health_Analytics_PowerPivot_Report.xlsx` as an Excel analysis deliverable.

**Documentation boundary:** Exact Power Query M steps, transformation order, refresh configuration and workbook-specific DAX should be exported from Excel if a verbatim, fully reproducible tutorial is required. Do not claim specific cleansing steps that are not saved in the source files.

## 8. Power BI model and measures

The report uses connected dimension/fact datasets and DAX to compute appointment and billing indicators. Core measures developed for this project include:

```dax
Total Appointments = COUNTROWS(FactAppointments)

Completed Appointments =
CALCULATE(
    COUNTROWS(FactAppointments),
    FactAppointments[AppointmentStatus] = "Completed"
)

No Show Appointments =
CALCULATE(
    COUNTROWS(FactAppointments),
    FactAppointments[AppointmentStatus] = "No Show"
)

No Show Rate = DIVIDE([No Show Appointments], [Total Appointments])

Average Wait Time = AVERAGE(FactAppointments[WaitTimeDays])

Total Claims = COUNTROWS(FactBilling)
Total Charges = SUM(FactBilling[ChargeAmount])
Total Paid = SUM(FactBilling[PaidAmount])
Total Balance = SUM(FactBilling[BalanceAmount])
```

Additional metrics cover completed-visit duration, denial rates, completion rates and provider counts. The report also uses a what-if threshold parameter to dynamically classify departments by no-show rate and wait time. The DAX above reflects the recorded build workflow; obtain a complete model measure export from Power BI Desktop or a model editor for exact final-model definitions.

### Modeling consideration: financial filter context

`FactBilling` and `FactAppointments` can be connected both directly and indirectly through dimensions, creating ambiguous filter paths in Power BI. The project used an inactive appointment relationship and relationship-aware calculations for appointment-year billing views. Verify Year, Department and other slicer behavior against the finished Power BI model, particularly when comparing appointment-date trends with payment-date trends.

## 9. Power BI — five report pages

| Page | Analytics |
|---|---|
| Executive Overview | Network KPIs, monthly appointment activity, departmental no-show rates, insurance paid amounts, provider summary |
| Patient Access Analysis | Appointment status distribution, no-show rates by appointment type, wait-time bands, departmental waits |
| Provider Performance | Top 10 providers, specialty comparison, completion and no-show matrix, provider workload scatter |
| Wait Time & Access Risk Lab | High/medium/low risk counts, adjustable threshold, department classification, risk matrix, wait-vs-no-show scatter |
| Revenue Cycle Analysis | Claim counts, charges, paid amounts and balances, claim statuses, insurance denial rates, appointment-month payments |

The report is presented in a consistent dark-navy/cyan design. User-facing outputs are exported as PNG screenshots and PDF for readers who do not have Power BI Desktop.

## 10. Selected insights from the exported dashboard

- **25,000** appointments, **19,604** completed, **2,492** no-shows and **2,904** cancellations.
- Overall no-show rate **9.97%** and mean wait **14.10 days**.
- **Behavioral Health:** 18.39% departmental no-show rate.
- **Dermatology:** 24.69-day average wait.
- **Telehealth:** 13.23% no-show rate by appointment type.
- Approximately **$7.25M** in charges, **$3.91M** paid and **$2.73M** outstanding balance.
- **Medicaid:** 12.08% denial rate among insurance categories shown.
- Risk counts on a dashboard screenshot at a **10%** high no-show threshold: **4 high**, **3 medium**, **1 low** departments. These are custom *operational* rules, not validated clinical risk definitions.

## 11. Limitations and reproducibility

1. Fictional data cannot establish real-world healthcare performance or causal relationships.
2. The original simulated CSV source datasets were not supplied in the portfolio attachments and may be required to rebuild from scratch.
3. Saved SQL scripts contain a schema syntax issue, an omitted database-creation step, and a repeated business query; publish a clearly labeled corrected version if offering a runnable setup.
4. The SQL visit-duration definition can differ from the completed-visits-only Power BI metric.
5. Appointment-month billing charts should not be described as payment transaction-month cash flows.
6. Final slicer propagation and model relationship states should be demonstrated by a recorded validation test, not inferred from screenshots alone.

## 12. Suggested reader walkthrough

1. Review the SQL schema and database setup prerequisites.
2. Inspect the CSV ingestion and data validation queries.
3. Run business-analysis SQL aggregates and reconcile them with reported totals.
4. Open the Excel workbook to review spreadsheet exploration.
5. Open the `.pbix` file in Power BI Desktop, configure the SQL Server connection, and refresh as needed.
6. Navigate all five report pages and test year, department and insurance filters.
7. Use the risk threshold slider to explore the sensitivity of department classifications.

**Portfolio takeaway:** Demonstrates relational modeling, SQL validation, business-focused aggregation, spreadsheet analysis, DAX, report design and interactive operational risk exploration.
