-- Canyon Ranch Data Warehouse Implementation Script
-- This script creates a DW schema and data warehouse tables within the CanyonRanch database
-- Last Updated: 2025-04-30 - Added derived metrics for ratings and usage counts

USE CanyonRanch;
GO

-- Step 1: Create DW schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DW')
BEGIN
    EXEC('CREATE SCHEMA DW');
    PRINT 'DW schema created successfully.'
END
ELSE
BEGIN
    PRINT 'DW schema already exists.'
END
GO

-- Step 2: Drop existing dimension and fact tables if they exist (for clean implementation)
IF OBJECT_ID('CanyonRanch.DW.Fact_ReservationService', 'U') IS NOT NULL 
    DROP TABLE CanyonRanch.DW.Fact_ReservationService;

IF OBJECT_ID('CanyonRanch.DW.Dim_Service', 'U') IS NOT NULL 
    DROP TABLE CanyonRanch.DW.Dim_Service;

IF OBJECT_ID('CanyonRanch.DW.Dim_ServiceType', 'U') IS NOT NULL 
    DROP TABLE CanyonRanch.DW.Dim_ServiceType;

IF OBJECT_ID('CanyonRanch.DW.Dim_Date', 'U') IS NOT NULL 
    DROP TABLE CanyonRanch.DW.Dim_Date;

IF OBJECT_ID('CanyonRanch.DW.Dim_Customer', 'U') IS NOT NULL 
    DROP TABLE CanyonRanch.DW.Dim_Customer;

PRINT 'Dropped any existing DW tables.';
GO

-- Step 3: Create dimension tables

-- First, create Dim_ServiceType as it's needed by Dim_Service (snowflake schema)
CREATE TABLE CanyonRanch.DW.Dim_ServiceType (
    ServiceTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    ServiceTypeName NVARCHAR(50) NOT NULL,
    ServiceUsageCount INT DEFAULT 0,             -- DERIVED metric
    AvgTypeRating DECIMAL(3,2) NULL              -- DERIVED metric from aggregated service ratings
);
PRINT 'Dim_ServiceType table created with derived metrics.';

-- Create Dim_Date table with derived attributes
CREATE TABLE CanyonRanch.DW.Dim_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,                      -- Source
    DayOfWeek INT NOT NULL,                      -- DERIVED from FullDate
    DayName NVARCHAR(10) NOT NULL,               -- DERIVED from FullDate
    Month INT NOT NULL,                          -- DERIVED from FullDate
    MonthName NVARCHAR(10) NOT NULL,             -- DERIVED from FullDate
    Quarter INT NOT NULL,                        -- DERIVED from FullDate
    Year INT NOT NULL                            -- DERIVED from FullDate
);
PRINT 'Dim_Date table created.';

-- Create Dim_Customer table
CREATE TABLE CanyonRanch.DW.Dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,                     -- Business key from source system
    CustomerName NVARCHAR(100) NOT NULL,         -- Source
    Gender NVARCHAR(20) NULL,                    -- Source
    AgeGroup NVARCHAR(20) NULL,                  -- DERIVED from DateOfBirth
    LoyaltyLevel NVARCHAR(20) NULL               -- Source from LoyaltyProgram
);
PRINT 'Dim_Customer table created.';

-- Create Dim_Service table - now with ServiceTypeKey for snowflake schema and AvgRating
CREATE TABLE CanyonRanch.DW.Dim_Service (
    ServiceKey INT IDENTITY(1,1) PRIMARY KEY,
    ServiceID INT NOT NULL,                      -- Business key from source system
    ServiceName NVARCHAR(100) NOT NULL,          -- Source
    ServiceTypeKey INT NOT NULL,                 -- Foreign key to Dim_ServiceType
    Duration INT NOT NULL,                       -- Source
    Price DECIMAL(10,2) NOT NULL,                -- Source
    AvgRating DECIMAL(3,2) NULL,                 -- DERIVED from Feedback ratings
    CONSTRAINT FK_DimService_DimServiceType FOREIGN KEY (ServiceTypeKey) 
        REFERENCES CanyonRanch.DW.Dim_ServiceType (ServiceTypeKey)
);
PRINT 'Dim_Service table created with average rating.';

-- Step 4: Create fact table with foreign keys to dimension tables
CREATE TABLE CanyonRanch.DW.Fact_ReservationService (
    ReservationServiceKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ServiceKey INT NOT NULL,
    ServiceDate DATE NOT NULL,
    TimeSlot TIME(7) NOT NULL,
    Revenue DECIMAL(10,2) NOT NULL,
    ServiceCount INT NOT NULL DEFAULT 1,         -- Always 1 for additive counting
    ServiceDurationMinutes INT NOT NULL,         -- Copies the Duration for additive measure
    ServiceRevenueAmount DECIMAL(10,2) NOT NULL, -- Copies the Revenue for additive measure
    
    CONSTRAINT FK_Fact_ReservationService_DimDate FOREIGN KEY (DateKey) 
        REFERENCES CanyonRanch.DW.Dim_Date (DateKey),
    CONSTRAINT FK_Fact_ReservationService_DimCustomer FOREIGN KEY (CustomerKey) 
        REFERENCES CanyonRanch.DW.Dim_Customer (CustomerKey),
    CONSTRAINT FK_Fact_ReservationService_DimService FOREIGN KEY (ServiceKey) 
        REFERENCES CanyonRanch.DW.Dim_Service (ServiceKey)
);
PRINT 'Fact_ReservationService table created.';

-- Step 5: Add indexes to improve query performance
CREATE INDEX IX_Fact_ReservationService_DateKey 
    ON CanyonRanch.DW.Fact_ReservationService (DateKey);

CREATE INDEX IX_Fact_ReservationService_CustomerKey 
    ON CanyonRanch.DW.Fact_ReservationService (CustomerKey);

CREATE INDEX IX_Fact_ReservationService_ServiceKey 
    ON CanyonRanch.DW.Fact_ReservationService (ServiceKey);

CREATE INDEX IX_Fact_ReservationService_ServiceDate 
    ON CanyonRanch.DW.Fact_ReservationService (ServiceDate);

CREATE INDEX IX_Dim_Customer_CustomerID 
    ON CanyonRanch.DW.Dim_Customer (CustomerID);

CREATE INDEX IX_Dim_Service_ServiceID 
    ON CanyonRanch.DW.Dim_Service (ServiceID);

CREATE INDEX IX_Dim_Service_ServiceTypeKey
    ON CanyonRanch.DW.Dim_Service (ServiceTypeKey);

-- Add index for the rating column to support queries filtering by rating
CREATE INDEX IX_Dim_Service_AvgRating
    ON CanyonRanch.DW.Dim_Service (AvgRating);

-- Add index for the service type rating for performance
CREATE INDEX IX_Dim_ServiceType_AvgTypeRating
    ON CanyonRanch.DW.Dim_ServiceType (AvgTypeRating);

PRINT 'Added indexes to improve query performance.';

-- Print success message with timestamp
DECLARE @CurrentTime DATETIME = GETDATE()
PRINT '----------------------------------------------';
PRINT 'Canyon Ranch DW tables created successfully.';
PRINT 'Snowflake schema implemented with Dim_ServiceType.';
PRINT 'Added derived metrics for ratings and usage counts.';
PRINT 'Tables created in schema: DW';
PRINT 'Completion time: ' + CONVERT(VARCHAR, @CurrentTime, 126);
PRINT '----------------------------------------------';
PRINT 'Next steps:';
PRINT '1. Populate Dim_ServiceType from Service table ServiceType values';
PRINT '2. Populate Dim_Date with calendar data';
PRINT '3. Populate Dim_Customer from Customer table';
PRINT '4. Populate Dim_Service from Service table (linking to Dim_ServiceType)';
PRINT '5. Update Dim_Service with average ratings from Feedback';
PRINT '6. Update Dim_ServiceType with usage counts and aggregated ratings';
PRINT '7. Populate Fact_ReservationService from ReservationService';
PRINT '----------------------------------------------';
GO
