# Data dictionary

Source: `01_Create_Database_and_Tables.sql`. SQL data types and fields below are transcribed from the supplied schema.

The dataset is **synthetic**; no real patient records are included in this project.

## `DimPatient`

| Column | SQL type | Notes |
|---|---|---|
| `PatientID` | `INT` | Primary key |
| `Age` | `INT` | Source field |
| `Gender` | `VARCHAR(20)` | Source field |
| `Zipcode` | `VARCHAR(10)` | Source field |
| `PatientSegment` | `VARCHAR(50)` | Source field |

## `DimProvider`

| Column | SQL type | Notes |
|---|---|---|
| `ProviderID` | `INT` | Primary key |
| `ProviderName` | `VARCHAR(100)` | Source field |
| `Specialty` | `VARCHAR(100)` | Source field |

## `DimDepartment`

| Column | SQL type | Notes |
|---|---|---|
| `DepartmentID` | `INT` | Primary key |
| `DepartmentName` | `VARCHAR(100)` | Source field |

## `DimInsurance`

| Column | SQL type | Notes |
|---|---|---|
| `InsuranceID` | `INT` | Primary key |
| `InsuranceType` | `VARCHAR(50)` | Source field |

## `DimDate`

| Column | SQL type | Notes |
|---|---|---|
| `DateID` | `INT` | Primary key |
| `FullDate` | `DATE` | Source field |
| `Year` | `INT` | Source field |
| `Quarter` | `INT` | Source field |
| `Month` | `INT` | Source field |
| `MonthName` | `VARCHAR(20)` | Source field |

## `FactAppointments`

| Column | SQL type | Notes |
|---|---|---|
| `AppointmentID` | `INT` | Primary key |
| `PatientID` | `INT` | FK — see relationships |
| `ProviderID` | `INT` | FK — see relationships |
| `DepartmentID` | `INT` | FK — see relationships |
| `DateID` | `INT` | FK — see relationships |
| `AppointmentDate` | `DATE` | Source field |
| `AppointmentStatus` | `VARCHAR(30)` | Source field |
| `AppointmentType` | `VARCHAR(50)` | Source field |
| `WaitTimeDays` | `INT` | Source field |
| `VisitDurationMinutes` | `INT` | Source field |

## `FactBilling`

| Column | SQL type | Notes |
|---|---|---|
| `BillingID` | `INT` | Primary key |
| `AppointmentID` | `INT` | FK — see relationships |
| `PatientID` | `INT` | FK — see relationships |
| `InsuranceID` | `INT` | FK — see relationships |
| `ChargeAmount` | `DECIMAL(10,2)` | Source field |
| `PaidAmount` | `DECIMAL(10,2)` | Source field |
| `AdjustmentAmount` | `DECIMAL(10,2)` | Source field |
| `BalanceAmount` | `DECIMAL(10,2)` | Source field |
| `ClaimStatus` | `VARCHAR(30)` | Source field |
| `PaymentDate` | `DATE` | Source field |

## Declared SQL relationships

- `FactAppointments.PatientID → DimPatient.PatientID`
- `FactAppointments.ProviderID → DimProvider.ProviderID`
- `FactAppointments.DepartmentID → DimDepartment.DepartmentID`
- `FactAppointments.DateID → DimDate.DateID`
- `FactBilling.AppointmentID → FactAppointments.AppointmentID`
- `FactBilling.PatientID → DimPatient.PatientID`
- `FactBilling.InsuranceID → DimInsurance.InsuranceID`

**Power BI caveat:** SQL constraints and Power BI relationship activation are separate; the billing-to-appointment relationship may be inactive in Power BI due to multiple filter paths.
