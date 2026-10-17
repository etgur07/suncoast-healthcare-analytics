# DAX Measures & Interactive Risk Logic

**Project:** Suncoast Health Network — Healthcare Operations Analytics  
**Data:** Synthetic healthcare appointments and billing, 2023–2025

> **Verification note:** The calculations below are documented from the formulas developed during the Power BI build and checked against displayed dashboard results where possible. The uploaded `.pbix` contains a binary `DataModel`; this document is **not** an automatic, complete export of all measures from the final semantic model. Verify expressions against the final report's Model view before treating this file as an authoritative code export.

## 1. Appointment activity

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
CALCULATE(
    AVERAGE(FactAppointments[VisitDurationMinutes]),
    FactAppointments[AppointmentStatus] = "Completed",
    FactAppointments[VisitDurationMinutes] > 0
)

Active Providers = DISTINCTCOUNT(FactAppointments[ProviderID])
```

- Format `No Show Rate` and `Completion Rate` as percentages.
- `Average Wait Time` uses days; `Average Visit Duration` uses minutes.
- At the unfiltered report level, the displayed results were: 25,000 appointments, 19,604 completed, 2,904 cancelled, 2,492 no-shows, 9.97% no-show rate, 78.42% completion rate, 14.10 days average wait and 39.18 minutes average completed visit.

## 2. Financial measures

```dax
Total Claims = COUNTROWS(FactBilling)
Total Charges = SUM(FactBilling[ChargeAmount])
Total Paid = SUM(FactBilling[PaidAmount])
Total Balance = SUM(FactBilling[BalanceAmount])

Denied Claims =
CALCULATE(COUNTROWS(FactBilling), FactBilling[ClaimStatus] = "Denied")

Denial Rate = DIVIDE([Denied Claims], [Total Claims])
```

These base measures aggregate billing rows. The report displays approximately 19,604 claims, $7.25M charges, $3.91M paid, $2.73M balance and 6.79% denial rate. These are rounded report-display values, not precise amounts for reconciliation.

## 3. Appointment-year-aware financial measures

The report-building workflow identified an inactive relationship between `FactBilling[AppointmentID]` and `FactAppointments[AppointmentID]`. The `DimDate[Year]` slicer initially changed appointment KPIs but left the original paid amount unchanged. An explicit relationship-aware measure was tested and successfully responded to the year selection.

```dax
Total Paid by Appointment Year =
CALCULATE(
    [Total Paid],
    USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID])
)

Total Claims by Appointment Year =
CALCULATE(
    [Total Claims],
    USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID])
)

Total Charges by Appointment Year =
CALCULATE(
    [Total Charges],
    USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID])
)

Total Balance by Appointment Year =
CALCULATE(
    [Total Balance],
    USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID])
)

Denied Claims by Appointment Year =
CALCULATE(
    [Denied Claims],
    USERELATIONSHIP(FactBilling[AppointmentID], FactAppointments[AppointmentID])
)

Denial Rate by Appointment Year =
DIVIDE([Denied Claims by Appointment Year], [Total Claims by Appointment Year])
```

**Interpretation:** These calculations organize financial outcomes by the *appointment's date*, not by the actual `FactBilling[PaymentDate]`. For example, a payment received in 2025 for a 2024 appointment belongs to 2024 in an appointment-year-based analysis. Do not call the resulting line chart a cash-flow or payment-date trend.

**Model caveat:** `USERELATIONSHIP` changes relationship participation inside an individual measure. It does not by itself prove that every other dimension filter, every measure, or all alternate filter paths behave correctly. Test slicer interactions and totals in the final model.

## 4. Waiting-time bands

Calculated columns in `FactAppointments`:

```dax
Wait Time Band =
SWITCH(
    TRUE(),
    FactAppointments[WaitTimeDays] <= 7, "0-7 days",
    FactAppointments[WaitTimeDays] <= 14, "8-14 days",
    FactAppointments[WaitTimeDays] <= 21, "15-21 days",
    "22+ days"
)

Wait Time Band Sort =
SWITCH(
    TRUE(),
    FactAppointments[WaitTimeDays] <= 7, 1,
    FactAppointments[WaitTimeDays] <= 14, 2,
    FactAppointments[WaitTimeDays] <= 21, 3,
    4
)
```

Set `Wait Time Band` → **Column tools → Sort by column** → `Wait Time Band Sort` to retain logical order. `DimDate[MonthName]` was similarly sorted by `DimDate[Month]`.

## 5. What-if parameter and department risk

Numeric What-if parameter `High No-Show Threshold`: minimum 0.05, maximum 0.25, increment 0.01, default 0.12 in the build workflow. The final exported PDF illustrates a selected 10% threshold. These are **custom illustrative operational categories**, not validated clinical risk grades.

```dax
Selected No-Show Threshold =
SELECTEDVALUE('High No-Show Threshold'[High No-Show Threshold], 0.12)

Dynamic High Risk Departments =
VAR Threshold = [Selected No-Show Threshold]
RETURN
COUNTROWS(
    FILTER(
        VALUES(DimDepartment[DepartmentID]),
        [Total Appointments] > 0 &&
        ([No Show Rate] >= Threshold || [Average Wait Time] >= 18)
    )
)

Dynamic Medium Risk Departments =
VAR Threshold = [Selected No-Show Threshold]
RETURN
COUNTROWS(
    FILTER(
        VALUES(DimDepartment[DepartmentID]),
        VAR Rate = [No Show Rate]
        VAR WaitDays = [Average Wait Time]
        VAR IsHigh = Rate >= Threshold || WaitDays >= 18
        VAR IsMedium = Rate >= 0.08 || WaitDays >= 14
        RETURN [Total Appointments] > 0 && NOT IsHigh && IsMedium
    )
)

Dynamic Low Risk Departments =
VAR ActiveDepartments =
    COUNTROWS(
        FILTER(
            VALUES(DimDepartment[DepartmentID]),
            [Total Appointments] > 0
        )
    )
RETURN ActiveDepartments - [Dynamic High Risk Departments] - [Dynamic Medium Risk Departments]
```

The developed risk-level measure used the same logic for each department: **High** if no-show rate reaches the selected threshold **or** wait time reaches 18 days; otherwise **Medium** if no-show rate reaches 8% **or** wait time reaches 14 days; otherwise **Low**. The finalized matrix also suppressed a misleading network-wide total risk label.

At the **10%** threshold, the final PDF shows **4 High, 3 Medium, 1 Low** (eight departments). A threshold change may move departments between High and Medium without changing Low, because the Medium minimum remains at 8% or 14 days.

### Risk colour measures (documented implementation example)

```dax
Department Risk Background Color =
SWITCH(
    [Department Risk Level],
    "High", "#7F3042",
    "Medium", "#735215",
    "Low", "#105C55",
    "#102F49"
)

Department Risk Text Color =
SWITCH(
    [Department Risk Level],
    "High", "#FDA4AF",
    "Medium", "#FDE68A",
    "Low", "#5EEAD4",
    "#00D4E8"
)
```

*The exact formatting expressions and colors should be compared with the final saved PBIX; these were among the measures discussed during dashboard formatting.*

## 6. Recommended final QA

1. Confirm percentages are formatted in Power BI as percentage values, not raw decimal ratios.
2. Compare financial KPIs with **Year = All** and **Year = 2024**; verify all financial cards and charts respond as intended.
3. Confirm `FactBilling` date semantics: appointment month versus payment date.
4. Test the What-if slider at 10%, 12%, and 15% and verify High + Medium + Low equals the active department count.
5. Confirm provider-level visuals identify providers using `ProviderID` or a unique provider label to avoid merging namesakes.
6. Export a measure list from Power BI or a compatible semantic-model editor to replace the reconstructed list above with a certified extract.
