# Suncoast Health Network — Data Dictionary

This dictionary is transcribed from the submitted `01_Create_Database_and_Tables.sql` DDL. All data is simulated. SQL types and field names reflect that submitted script (including its noted syntax caveat).

## DimPatient

| Column | SQL type | Meaning |
|---|---|---|
| PatientID | INT, PK | Patient identifier |
| Age | INT | Age |
| Gender | VARCHAR(20) | Reported gender field |
| Zipcode | VARCHAR(10) | Postal code |
| PatientSegment | VARCHAR(50) | Segment/category |

## DimProvider

| Column | SQL type | Meaning |
|---|---|---|
| ProviderID | INT, PK | Unique provider identifier |
| ProviderName | VARCHAR(100) | Display name (not necessarily unique) |
| Specialty | VARCHAR(100) | Specialty/category |

## DimDepartment

| Column | SQL type | Meaning |
|---|---|---|
| DepartmentID | INT, PK | Department identifier |
| DepartmentName | VARCHAR(100) | Department label |

## DimInsurance

| Column | SQL type | Meaning |
|---|---|---|
| InsuranceID | INT, PK | Insurance category identifier |
| InsuranceType | VARCHAR(50) | Insurance label |

## DimDate

| Column | SQL type | Meaning |
|---|---|---|
| DateID | INT, PK | Date dimension key |
| FullDate | DATE | Calendar date |
| Year | INT | Year |
| Quarter | INT | Calendar quarter number |
| Month | INT | Month number |
| MonthName | VARCHAR(20) | Month label |

## FactAppointments

| Column | SQL type | Meaning |
|---|---|---|
| AppointmentID | INT, PK | Unique appointment identifier |
| PatientID | INT, FK → DimPatient | Patient |
| ProviderID | INT, FK → DimProvider | Provider |
| DepartmentID | INT, FK → DimDepartment | Department |
| DateID | INT, FK → DimDate | Date dimension key |
| AppointmentDate | DATE | Appointment date |
| AppointmentStatus | VARCHAR(30) | Completed / Cancelled / No Show, as used in analytics |
| AppointmentType | VARCHAR(50) | Appointment category |
| WaitTimeDays | INT | Wait time in days |
| VisitDurationMinutes | INT | Recorded visit duration |

## FactBilling

| Column | SQL type | Meaning |
|---|---|---|
| BillingID | INT, PK | Unique billing record |
| AppointmentID | INT, FK → FactAppointments | Associated appointment |
| PatientID | INT, FK → DimPatient | Patient |
| InsuranceID | INT, FK → DimInsurance | Insurance category |
| ChargeAmount | DECIMAL(10,2) | Charged amount |
| PaidAmount | DECIMAL(10,2) | Amount paid |
| AdjustmentAmount | DECIMAL(10,2) | Billing adjustment |
| BalanceAmount | DECIMAL(10,2) | Balance amount |
| ClaimStatus | VARCHAR(30) | Claim status (e.g., Paid, Pending, Denied) |
| PaymentDate | DATE | Date associated with payment |

## Relationship notes

- The SQL schema declares referential constraints from `FactAppointments` to four dimensions and from `FactBilling` to the appointment, patient and insurance tables.
- `DimProvider.ProviderName` is descriptive, not declared unique.
- The SQL schema does **not** declare a unique constraint on `FactBilling.AppointmentID`; verify whether each appointment has at most one billing row before assuming a strict one-to-one relation.
- Some Power BI relationships may be inactive to avoid ambiguous filter paths; do not assume SQL foreign keys map to active Power BI relationships automatically.
