# DAX measure reference — verify before publication

The code below reconstructs measures discussed and implemented during development; it is **not a verified full extraction** from the PBIX model. Check formula names, table names and relationship activation inside Power BI Desktop before claiming exact parity.

```dax
Total Appointments = COUNTROWS(FactAppointments)

Completed Appointments =
CALCULATE(COUNTROWS(FactAppointments), FactAppointments[AppointmentStatus] = "Completed")

Cancelled Appointments =
CALCULATE(COUNTROWS(FactAppointments), FactAppointments[AppointmentStatus] = "Cancelled")

No Show Appointments =
CALCULATE(COUNTROWS(FactAppointments), FactAppointments[AppointmentStatus] = "No Show")

No Show Rate = DIVIDE([No Show Appointments], [Total Appointments])

Completion Rate = DIVIDE([Completed Appointments], [Total Appointments])

Average Wait Time = AVERAGE(FactAppointments[WaitTimeDays])

Average Visit Duration =
CALCULATE(AVERAGE(FactAppointments[VisitDurationMinutes]),
  FactAppointments[AppointmentStatus] = "Completed",
  FactAppointments[VisitDurationMinutes] > 0)

Active Providers = DISTINCTCOUNT(FactAppointments[ProviderID])

Total Claims = COUNTROWS(FactBilling)
Total Charges = SUM(FactBilling[ChargeAmount])
Total Paid = SUM(FactBilling[PaidAmount])
Total Balance = SUM(FactBilling[BalanceAmount])

Denied Claims = CALCULATE(COUNTROWS(FactBilling), FactBilling[ClaimStatus] = "Denied")
Denial Rate = DIVIDE([Denied Claims], [Total Claims])

Total Paid by Appointment Year =
CALCULATE([Total Paid], USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID]))

Total Charges by Appointment Year =
CALCULATE([Total Charges], USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID]))

Total Claims by Appointment Year =
CALCULATE([Total Claims], USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID]))

Total Balance by Appointment Year =
CALCULATE([Total Balance], USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID]))

Denied Claims by Appointment Year =
CALCULATE([Denied Claims], USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID]))

Denial Rate by Appointment Year =
DIVIDE([Denied Claims by Appointment Year], [Total Claims by Appointment Year])

Selected No-Show Threshold =
SELECTEDVALUE('High No-Show Threshold'[High No-Show Threshold], 0.12)

Department Risk Level =
IF(NOT ISINSCOPE(DimDepartment[DepartmentName]), BLANK(),
 VAR Threshold = [Selected No-Show Threshold]
 VAR Rate = [No Show Rate]
 VAR WaitDays = [Average Wait Time]
 RETURN SWITCH(TRUE(),
   ISBLANK([Total Appointments]) || [Total Appointments] = 0, BLANK(),
   Rate >= Threshold || WaitDays >= 18, "High",
   Rate >= 0.08 || WaitDays >= 14, "Medium",
   "Low"))
```

## Selected calculated columns

```dax
Wait Time Band =
SWITCH(TRUE(),
 FactAppointments[WaitTimeDays] <= 7, "0-7 days",
 FactAppointments[WaitTimeDays] <= 14, "8-14 days",
 FactAppointments[WaitTimeDays] <= 21, "15-21 days",
 "22+ days")

Wait Time Band Sort =
SWITCH(TRUE(),
 FactAppointments[WaitTimeDays] <= 7, 1,
 FactAppointments[WaitTimeDays] <= 14, 2,
 FactAppointments[WaitTimeDays] <= 21, 3,
 4)
```

## Dynamic risk count caveat

The department-level counts were implemented using `VALUES(DimDepartment[DepartmentID])` and evaluated the above criteria at department grain. If the presentation uses a `Department Risk Level` measure with `ISINSCOPE`, do not reuse that measure directly inside an iterator without checking the filter context; use the dedicated dynamic risk count measures instead.
