-- Publication edits: removed duplicate Department Performance Summary; provider grouped by ProviderID.
-- Business Analysis originally written for the simulated Suncoast dataset.

/*
Business Analysis 1: Executive Appointment KPIs

Purpose:
This query provides a high-level overview of appointment performance for the healthcare network.

It calculates:
- Total number of appointments
- Completed appointments
- Cancelled appointments
- No-show appointments
- No-show rate percentage
- Average wait time in days

Business value:
This helps identify overall appointment volume, patient attendance behavior,
and access efficiency across the organization.
*/

USE SuncoastHealthAnalytics;
GO

SELECT
    COUNT(*) AS TotalAppointments,

    SUM(CASE 
            WHEN AppointmentStatus = 'Completed' THEN 1 
            ELSE 0 
        END) AS CompletedAppointments,

    SUM(CASE 
            WHEN AppointmentStatus = 'Cancelled' THEN 1 
            ELSE 0 
        END) AS CancelledAppointments,

    SUM(CASE 
            WHEN AppointmentStatus = 'No Show' THEN 1 
            ELSE 0 
        END) AS NoShowAppointments,

    CAST(
        SUM(CASE 
                WHEN AppointmentStatus = 'No Show' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS NoShowRatePercent,

    CAST(
        AVG(CAST(WaitTimeDays AS DECIMAL(10,2))) 
        AS DECIMAL(10,2)
    ) AS AverageWaitTimeDays

FROM FactAppointments;

-- 2. No-Show Rate by Department

SELECT
    d.DepartmentName,
    COUNT(*) AS TotalAppointments,

    SUM(CASE 
            WHEN a.AppointmentStatus = 'No Show' THEN 1 
            ELSE 0 
        END) AS NoShowAppointments,

    CAST(
        SUM(CASE 
                WHEN a.AppointmentStatus = 'No Show' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS NoShowRatePercent

FROM FactAppointments a
INNER JOIN DimDepartment d
    ON a.DepartmentID = d.DepartmentID

GROUP BY d.DepartmentName

ORDER BY NoShowRatePercent DESC;

-- 3. Monthly Appointment Trend

SELECT
    dt.Year,
    dt.Month,
    dt.MonthName,
    COUNT(*) AS TotalAppointments
FROM FactAppointments a
INNER JOIN DimDate dt
    ON a.DateID = dt.DateID
GROUP BY
    dt.Year,
    dt.Month,
    dt.MonthName
ORDER BY
    dt.Year,
    dt.Month;


 -- 4. Revenue KPIs

SELECT
    COUNT(*) AS TotalClaims,

    CAST(SUM(ChargeAmount) AS DECIMAL(12,2)) AS TotalCharges,

    CAST(SUM(PaidAmount) AS DECIMAL(12,2)) AS TotalPaid,

    CAST(SUM(AdjustmentAmount) AS DECIMAL(12,2)) AS TotalAdjustments,

    CAST(SUM(BalanceAmount) AS DECIMAL(12,2)) AS TotalBalance,

    SUM(CASE 
            WHEN ClaimStatus = 'Denied' THEN 1 
            ELSE 0 
        END) AS DeniedClaims,

    CAST(
        SUM(CASE 
                WHEN ClaimStatus = 'Denied' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS DenialRatePercent

FROM FactBilling;

-- 5. Revenue by Insurance Type

SELECT
    i.InsuranceType,

    COUNT(*) AS TotalClaims,

    CAST(SUM(b.ChargeAmount) AS DECIMAL(12,2)) AS TotalCharges,

    CAST(SUM(b.PaidAmount) AS DECIMAL(12,2)) AS TotalPaid,

    CAST(SUM(b.BalanceAmount) AS DECIMAL(12,2)) AS TotalBalance

FROM FactBilling b
INNER JOIN DimInsurance i
    ON b.InsuranceID = i.InsuranceID

GROUP BY i.InsuranceType

ORDER BY TotalPaid DESC;

-- 6. Claim Status Breakdown

SELECT
    ClaimStatus,
    COUNT(*) AS TotalClaims,

    CAST(
        COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM FactBilling)
        AS DECIMAL(5,2)
    ) AS ClaimStatusPercent

FROM FactBilling

GROUP BY ClaimStatus

ORDER BY TotalClaims DESC;

-- 7. Denial Rate by Insurance Type

SELECT
    i.InsuranceType,

    COUNT(*) AS TotalClaims,

    SUM(CASE 
            WHEN b.ClaimStatus = 'Denied' THEN 1 
            ELSE 0 
        END) AS DeniedClaims,

    CAST(
        SUM(CASE 
                WHEN b.ClaimStatus = 'Denied' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS DenialRatePercent

FROM FactBilling b
INNER JOIN DimInsurance i
    ON b.InsuranceID = i.InsuranceID

GROUP BY i.InsuranceType

ORDER BY DenialRatePercent DESC;

-- 8. Average Wait Time by Department

SELECT
    d.DepartmentName,

    COUNT(*) AS TotalAppointments,

    CAST(
        AVG(CAST(a.WaitTimeDays AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageWaitTimeDays

FROM FactAppointments a
INNER JOIN DimDepartment d
    ON a.DepartmentID = d.DepartmentID

GROUP BY d.DepartmentName

ORDER BY AverageWaitTimeDays DESC;

-- 9. Provider Performance

SELECT
    p.ProviderID,
    p.ProviderName,
    p.Specialty,

    COUNT(*) AS TotalAppointments,

    SUM(CASE 
            WHEN a.AppointmentStatus = 'Completed' THEN 1 
            ELSE 0 
        END) AS CompletedAppointments,

    SUM(CASE 
            WHEN a.AppointmentStatus = 'No Show' THEN 1 
            ELSE 0 
        END) AS NoShowAppointments,

    CAST(
        SUM(CASE 
                WHEN a.AppointmentStatus = 'No Show' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NoShowRatePercent,

    CAST(
        AVG(CAST(a.VisitDurationMinutes AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageVisitDurationMinutes

FROM FactAppointments a
INNER JOIN DimProvider p
    ON a.ProviderID = p.ProviderID

GROUP BY
    p.ProviderID,
    p.ProviderName,
    p.Specialty

ORDER BY TotalAppointments DESC;

-- 10. Department Performance Summary

SELECT
    d.DepartmentName,

    COUNT(a.AppointmentID) AS TotalAppointments,

    SUM(CASE 
            WHEN a.AppointmentStatus = 'Completed' THEN 1 
            ELSE 0 
        END) AS CompletedAppointments,

    SUM(CASE 
            WHEN a.AppointmentStatus = 'No Show' THEN 1 
            ELSE 0 
        END) AS NoShowAppointments,

    CAST(
        SUM(CASE 
                WHEN a.AppointmentStatus = 'No Show' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(a.AppointmentID)
        AS DECIMAL(5,2)
    ) AS NoShowRatePercent,

    CAST(
        AVG(CAST(a.WaitTimeDays AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageWaitTimeDays,

    CAST(
        SUM(ISNULL(b.PaidAmount, 0))
        AS DECIMAL(12,2)
    ) AS TotalPaid,

    SUM(CASE 
            WHEN b.ClaimStatus = 'Denied' THEN 1 
            ELSE 0 
        END) AS DeniedClaims,

    CAST(
        SUM(CASE 
                WHEN b.ClaimStatus = 'Denied' THEN 1 
                ELSE 0 
            END) * 100.0 / NULLIF(COUNT(b.BillingID), 0)
        AS DECIMAL(5,2)
    ) AS DenialRatePercent

FROM FactAppointments a

INNER JOIN DimDepartment d
    ON a.DepartmentID = d.DepartmentID

LEFT JOIN FactBilling b
    ON a.AppointmentID = b.AppointmentID

GROUP BY d.DepartmentName

ORDER BY TotalAppointments DESC;
