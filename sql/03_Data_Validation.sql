-- Validation queries: missing foreign-key references, duplicate IDs, missing required values, row counts.
-- Rerun after import. Results are not included in the original source scripts.

USE SuncoastHealthAnalytics;
GO

SELECT 'Missing Patient IDs in Appointments' AS ValidationCheck,
       COUNT(*) AS IssueCount
FROM FactAppointments a
LEFT JOIN DimPatient p
    ON a.PatientID = p.PatientID
WHERE p.PatientID IS NULL

UNION ALL

SELECT 'Missing Provider IDs in Appointments',
       COUNT(*)
FROM FactAppointments a
LEFT JOIN DimProvider pr
    ON a.ProviderID = pr.ProviderID
WHERE pr.ProviderID IS NULL

UNION ALL

SELECT 'Missing Department IDs in Appointments',
       COUNT(*)
FROM FactAppointments a
LEFT JOIN DimDepartment d
    ON a.DepartmentID = d.DepartmentID
WHERE d.DepartmentID IS NULL

UNION ALL

SELECT 'Missing Date IDs in Appointments',
       COUNT(*)
FROM FactAppointments a
LEFT JOIN DimDate dt
    ON a.DateID = dt.DateID
WHERE dt.DateID IS NULL

UNION ALL

SELECT 'Missing Appointment IDs in Billing',
       COUNT(*)
FROM FactBilling b
LEFT JOIN FactAppointments a
    ON b.AppointmentID = a.AppointmentID
WHERE a.AppointmentID IS NULL

UNION ALL

SELECT 'Missing Insurance IDs in Billing',
       COUNT(*)
FROM FactBilling b
LEFT JOIN DimInsurance i
    ON b.InsuranceID = i.InsuranceID
WHERE i.InsuranceID IS NULL;

USE SuncoastHealthAnalytics;
GO

SELECT 'Duplicate PatientID' AS ValidationCheck,
       COUNT(*) AS DuplicateGroups
FROM (
    SELECT PatientID
    FROM DimPatient
    GROUP BY PatientID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT 'Duplicate ProviderID',
       COUNT(*)
FROM (
    SELECT ProviderID
    FROM DimProvider
    GROUP BY ProviderID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT 'Duplicate DepartmentID',
       COUNT(*)
FROM (
    SELECT DepartmentID
    FROM DimDepartment
    GROUP BY DepartmentID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT 'Duplicate InsuranceID',
       COUNT(*)
FROM (
    SELECT InsuranceID
    FROM DimInsurance
    GROUP BY InsuranceID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT 'Duplicate AppointmentID',
       COUNT(*)
FROM (
    SELECT AppointmentID
    FROM FactAppointments
    GROUP BY AppointmentID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT 'Duplicate BillingID',
       COUNT(*)
FROM (
    SELECT BillingID
    FROM FactBilling
    GROUP BY BillingID
    HAVING COUNT(*) > 1
) x;

USE SuncoastHealthAnalytics;
GO

SELECT 'Missing AppointmentStatus' AS ValidationCheck,
       COUNT(*) AS IssueCount
FROM FactAppointments
WHERE AppointmentStatus IS NULL

UNION ALL

SELECT 'Missing AppointmentType',
       COUNT(*)
FROM FactAppointments
WHERE AppointmentType IS NULL

UNION ALL

SELECT 'Missing PatientID in Appointments',
       COUNT(*)
FROM FactAppointments
WHERE PatientID IS NULL

UNION ALL

SELECT 'Missing ChargeAmount',
       COUNT(*)
FROM FactBilling
WHERE ChargeAmount IS NULL

UNION ALL

SELECT 'Missing PaidAmount',
       COUNT(*)
FROM FactBilling
WHERE PaidAmount IS NULL

UNION ALL

SELECT 'Missing ClaimStatus',
       COUNT(*)
FROM FactBilling
WHERE ClaimStatus IS NULL;

USE SuncoastHealthAnalytics;
GO

SELECT 'DimPatient' AS TableName, COUNT(*) AS TotalRows FROM DimPatient
UNION ALL
SELECT 'DimProvider', COUNT(*) FROM DimProvider
UNION ALL
SELECT 'DimDepartment', COUNT(*) FROM DimDepartment
UNION ALL
SELECT 'DimInsurance', COUNT(*) FROM DimInsurance
UNION ALL
SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL
SELECT 'FactAppointments', COUNT(*) FROM FactAppointments
UNION ALL
SELECT 'FactBilling', COUNT(*) FROM FactBilling;
