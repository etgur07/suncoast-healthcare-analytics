-- Original import logic retained. Update C:\SuncoastHealthDatasets paths to your SQL Server accessible directory.
-- CSV files are required and are NOT included in this repository.
-- Run AFTER 01_Create_Database_and_Tables.sql.

EXEC master.dbo.xp_fileexist 'C:\SuncoastHealthDatasets\DimPatient.csv';

USE SuncoastHealthAnalytics;
GO

BULK INSERT DimPatient
FROM 'C:\SuncoastHealthDatasets\DimPatient.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);


SELECT COUNT(*) AS PatientCount
FROM DimPatient;


USE SuncoastHealthAnalytics;
GO

BULK INSERT DimProvider
FROM 'C:\SuncoastHealthDatasets\DimProvider.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT DimDepartment
FROM 'C:\SuncoastHealthDatasets\DimDepartment.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT DimInsurance
FROM 'C:\SuncoastHealthDatasets\DimInsurance.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT DimDate
FROM 'C:\SuncoastHealthDatasets\DimDate.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);

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

USE SuncoastHealthAnalytics;
GO

BULK INSERT FactAppointments
FROM 'C:\SuncoastHealthDatasets\FactAppointments.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);

SELECT COUNT(*) AS AppointmentCount
FROM FactAppointments;

USE SuncoastHealthAnalytics;
GO

BULK INSERT FactBilling
FROM 'C:\SuncoastHealthDatasets\FactBilling.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
);

SELECT COUNT(*) AS BillingCount
FROM FactBilling;
