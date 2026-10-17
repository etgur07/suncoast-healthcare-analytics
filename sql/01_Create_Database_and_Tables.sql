-- Publication-ready version: adds CREATE DATABASE and removes trailing comma.
-- Requires SQL Server; run once on an empty database.

IF DB_ID(N'SuncoastHealthAnalytics') IS NULL
    CREATE DATABASE SuncoastHealthAnalytics;
GO

USE SuncoastHealthAnalytics;
GO

CREATE TABLE DimPatient (
  PatientID INT PRIMARY KEY,
  Age INT,
  Gender VARCHAR(20),
  Zipcode VARCHAR(10),
  PatientSegment VARCHAR (50)
);

CREATE TABLE DimProvider (
  ProviderID INT PRIMARY KEY,
  ProviderName VARCHAR(100),
  Specialty VARCHAR(100)
);

CREATE TABLE DimDepartment (
  DepartmentID INT PRIMARY KEY,
  DepartmentName VARCHAR(100)
);

CREATE TABLE DimInsurance (
  InsuranceID INT PRIMARY KEY,
  InsuranceType VARCHAR(50)
);

CREATE TABLE DimDate (
  DateID INT PRIMARY KEY,
  FullDate DATE,
  Year INT,
  Quarter INT,
  Month INT,
  MonthName VARCHAR(20)
);

CREATE TABLE FactAppointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT,
    ProviderID INT,
    DepartmentID INT,
    DateID INT,
    AppointmentDate DATE,
    AppointmentStatus VARCHAR(30),
    AppointmentType VARCHAR(50),
    WaitTimeDays INT,
    VisitDurationMinutes INT,
      CONSTRAINT FK_Appointments_Patient 
        FOREIGN KEY (PatientID) REFERENCES DimPatient(PatientID),
    CONSTRAINT FK_Appointments_Provider 
        FOREIGN KEY (ProviderID) REFERENCES DimProvider(ProviderID),
    CONSTRAINT FK_Appointments_Department 
        FOREIGN KEY (DepartmentID) REFERENCES DimDepartment(DepartmentID),
    CONSTRAINT FK_Appointments_Date 
        FOREIGN KEY (DateID) REFERENCES DimDate(DateID)
);


CREATE TABLE FactBilling (
   BillingID INT PRIMARY KEY,
   AppointmentID INT,
   PatientID INT,
   InsuranceID INT,
   ChargeAmount DECIMAL (10,2),
   PaidAmount DECIMAL (10,2),
   AdjustmentAmount DECIMAL (10,2),
   BalanceAmount DECIMAL (10,2),
   ClaimStatus VARCHAR (30),
   PaymentDate DATE,
 CONSTRAINT FK_Billing_Appointment 
        FOREIGN KEY (AppointmentID) REFERENCES FactAppointments(AppointmentID),
    CONSTRAINT FK_Billing_Patient 
        FOREIGN KEY (PatientID) REFERENCES DimPatient(PatientID),
    CONSTRAINT FK_Billing_Insurance 
        FOREIGN KEY (InsuranceID) REFERENCES DimInsurance(InsuranceID)
);
