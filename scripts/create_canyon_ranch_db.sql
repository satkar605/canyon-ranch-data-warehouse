-- Canyon Ranch Database Schema Creation Script v5
-- This script creates the CanyonRanch database schema and all tables
-- Key changes: Fixed relationship between Affiliate and ReferralSource tables, improved bridge table naming
-- Last Updated: 2025-04-24

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CanyonRanch')
BEGIN
    CREATE DATABASE CanyonRanch;
END
GO

USE CanyonRanch;
GO

-- =============================================
-- DROP ALL CONSTRAINTS FIRST WITH DYNAMIC SQL
-- This handles all dependency issues cleanly
-- =============================================

-- Disable all constraints first
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all";
GO

-- Drop all foreign key constraints
DECLARE @DropConstraints NVARCHAR(MAX) = '';

SELECT @DropConstraints = @DropConstraints + 
    'ALTER TABLE [' + OBJECT_SCHEMA_NAME(parent_object_id) + 
    '].[' + OBJECT_NAME(parent_object_id) + 
    '] DROP CONSTRAINT [' + name + '];' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys;

EXEC sp_executesql @DropConstraints;
GO

-- =============================================
-- DROP ALL TABLES IN A SAFE ORDER
-- =============================================

-- Drop all tables (with checks for existence)
IF OBJECT_ID('Affiliate_ReferralSource', 'U') IS NOT NULL DROP TABLE Affiliate_ReferralSource;
IF OBJECT_ID('Feedback', 'U') IS NOT NULL DROP TABLE Feedback;
IF OBJECT_ID('Payment', 'U') IS NOT NULL DROP TABLE Payment;
IF OBJECT_ID('LoyaltyProgram', 'U') IS NOT NULL DROP TABLE LoyaltyProgram;
IF OBJECT_ID('ReservationReservationServiceBridge', 'U') IS NOT NULL DROP TABLE ReservationReservationServiceBridge;
IF OBJECT_ID('StaffReservationServiceBridge', 'U') IS NOT NULL DROP TABLE StaffReservationServiceBridge;
IF OBJECT_ID('ReservationServiceServiceBridge', 'U') IS NOT NULL DROP TABLE ReservationServiceServiceBridge;
IF OBJECT_ID('FacilityServiceBridge', 'U') IS NOT NULL DROP TABLE FacilityServiceBridge;
IF OBJECT_ID('StaffServiceBridge', 'U') IS NOT NULL DROP TABLE StaffServiceBridge;
-- Drop legacy named tables if they exist
IF OBJECT_ID('Includes', 'U') IS NOT NULL DROP TABLE Includes;
IF OBJECT_ID('AssignedTo', 'U') IS NOT NULL DROP TABLE AssignedTo;
IF OBJECT_ID('RefersTo', 'U') IS NOT NULL DROP TABLE RefersTo;
IF OBJECT_ID('Provides', 'U') IS NOT NULL DROP TABLE Provides;
IF OBJECT_ID('QualifiesFor', 'U') IS NOT NULL DROP TABLE QualifiesFor;
IF OBJECT_ID('ReservationService', 'U') IS NOT NULL DROP TABLE ReservationService;
IF OBJECT_ID('Room', 'U') IS NOT NULL DROP TABLE Room;
IF OBJECT_ID('Reservation', 'U') IS NOT NULL DROP TABLE Reservation;
IF OBJECT_ID('Service', 'U') IS NOT NULL DROP TABLE Service;
IF OBJECT_ID('Staff', 'U') IS NOT NULL DROP TABLE Staff;
IF OBJECT_ID('ProgramCoordinator', 'U') IS NOT NULL DROP TABLE ProgramCoordinator;
IF OBJECT_ID('Affiliate', 'U') IS NOT NULL DROP TABLE Affiliate;
IF OBJECT_ID('ReferralSource', 'U') IS NOT NULL DROP TABLE ReferralSource;
IF OBJECT_ID('Customer', 'U') IS NOT NULL DROP TABLE Customer;
IF OBJECT_ID('Facility', 'U') IS NOT NULL DROP TABLE Facility;
GO

-- =============================================
-- CREATE TABLES - MAIN ENTITIES
-- =============================================

-- Create Facility Table
CREATE TABLE Facility (
    FacilityID INT PRIMARY KEY IDENTITY(1,1),
    FacilityName NVARCHAR(100) NOT NULL,
    FacilityType NVARCHAR(50) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(15) NOT NULL,
    OperatingHours NVARCHAR(MAX) NULL
);
GO

-- Create Customer Table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustFName NVARCHAR(50) NOT NULL,
    CustLName NVARCHAR(50) NOT NULL,
    CustMName NVARCHAR(50) NULL,
    CustomerEmail NVARCHAR(320) NOT NULL UNIQUE,
    CustomerPhone NVARCHAR(15) NOT NULL,
    CustomerAddress NVARCHAR(255) NOT NULL,
    Gender NVARCHAR(20) NULL,
    DateOfBirth DATE NOT NULL,
    Preferences NVARCHAR(MAX) NULL,
    MedicalHistory NVARCHAR(MAX) NULL,
    ReferralCount INT DEFAULT 0,
    VisitCount INT DEFAULT 0
);
GO

-- Create ReferralSource Table
CREATE TABLE ReferralSource (
    ReferralSourceID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    ReferrerType NVARCHAR(20) NOT NULL,
    ReferrerID INT NULL,     -- This could be CustomerID depending on ReferrerType
    CONSTRAINT FK_ReferralSource_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
GO

-- Create Affiliate Table (Modified to add ReferralSourceID as FK)
CREATE TABLE Affiliate (
    AffiliateID INT PRIMARY KEY IDENTITY(1,1),
    AffiliateName NVARCHAR(100) NOT NULL,
    AffiliateContact NVARCHAR(100) NOT NULL,
    ReferralCount INT NOT NULL DEFAULT 0,
    ReferralSourceID INT NULL,  -- Added FK column
    CONSTRAINT FK_Affiliate_ReferralSource 
        FOREIGN KEY (ReferralSourceID) REFERENCES ReferralSource(ReferralSourceID)
);
GO

-- Create Program Coordinator Table
CREATE TABLE ProgramCoordinator (
    PCID INT PRIMARY KEY IDENTITY(1,1),
    PCFName NVARCHAR(50) NOT NULL,
    PCLName NVARCHAR(50) NOT NULL,
    PCMName NVARCHAR(50) NULL,
    PCEmail NVARCHAR(320) NOT NULL UNIQUE,
    PCPhone NVARCHAR(15) NOT NULL,
    AssignedReservations INT DEFAULT 0,
    ShiftSchedule NVARCHAR(MAX) NULL,
    FacilityID INT,
    CONSTRAINT FK_ProgramCoordinator_Facility FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID)
);
GO

-- Create Staff Table
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    StaffFName NVARCHAR(50) NOT NULL,
    StaffLName NVARCHAR(50) NOT NULL,
    StaffMName NVARCHAR(50) NULL,
    StaffRole NVARCHAR(50) NOT NULL,
    Specialty NVARCHAR(100) NULL,
    Availability NVARCHAR(MAX) NULL,
    FacilityID INT,
    CONSTRAINT FK_Staff_Facility FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID)
);
GO

-- Create Service Table
CREATE TABLE Service (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceName NVARCHAR(100) NOT NULL,
    ServiceType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Duration INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Capacity INT NOT NULL
);
GO

-- Create Reservation Table
CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    ReservationDate DATETIME NOT NULL DEFAULT GETDATE(),
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    ReservationType NVARCHAR(50) NOT NULL,
    SpecialRequests NVARCHAR(MAX) NULL,
    NoOfGuests INT NOT NULL DEFAULT 1,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    PCID INT,
    CONSTRAINT FK_Reservation_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Reservation_ProgramCoordinator FOREIGN KEY (PCID) REFERENCES ProgramCoordinator(PCID),
    CONSTRAINT CK_Reservation_Dates CHECK (CheckOutDate > CheckInDate)
);
GO

-- Create Room Table
CREATE TABLE Room (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    FacilityID INT,
    RoomType NVARCHAR(50) NOT NULL,
    RoomRate DECIMAL(10,2) NOT NULL,
    Capacity INT NOT NULL,
    RoomStatus NVARCHAR(20) NOT NULL DEFAULT 'Available',
    Amenities NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Room_Facility FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID)
);
GO

-- Create ReservationService Table
CREATE TABLE ReservationService (
    ReservationServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceDate DATE NOT NULL,
    TimeSlot TIME(7) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Booked',
    Notes NVARCHAR(MAX) NULL,
    Price DECIMAL(10,2) NOT NULL
);
GO

-- Create FacilityServiceBridge Table (Bridge between Facility and Service)
CREATE TABLE FacilityServiceBridge (
    FacilityID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (FacilityID, ServiceID),
    CONSTRAINT FK_FacilityServiceBridge_Facility FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID),
    CONSTRAINT FK_FacilityServiceBridge_Service FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID)
);
GO

-- Create StaffServiceBridge Table (Bridge between Staff and Service)
CREATE TABLE StaffServiceBridge (
    StaffID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (StaffID, ServiceID),
    CONSTRAINT FK_StaffServiceBridge_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_StaffServiceBridge_Service FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID)
);
GO

-- Create ReservationReservationServiceBridge Table (Bridge between Reservation and ReservationService)
CREATE TABLE ReservationReservationServiceBridge (
    ReservationID INT NOT NULL,
    ReservationServiceID INT NOT NULL,
    PRIMARY KEY (ReservationID, ReservationServiceID),
    CONSTRAINT FK_ReservationReservationServiceBridge_Reservation FOREIGN KEY (ReservationID) 
        REFERENCES Reservation(ReservationID),
    CONSTRAINT FK_ReservationReservationServiceBridge_ReservationService FOREIGN KEY (ReservationServiceID) 
        REFERENCES ReservationService(ReservationServiceID)
);
GO

-- Create StaffReservationServiceBridge Table (Bridge between Staff and ReservationService)
-- Removed AssignedDate column as requested
CREATE TABLE StaffReservationServiceBridge (
    StaffID INT NOT NULL,
    ReservationServiceID INT NOT NULL,
    PRIMARY KEY (StaffID, ReservationServiceID),
    CONSTRAINT FK_StaffReservationServiceBridge_Staff FOREIGN KEY (StaffID) 
        REFERENCES Staff(StaffID),
    CONSTRAINT FK_StaffReservationServiceBridge_ReservationService FOREIGN KEY (ReservationServiceID) 
        REFERENCES ReservationService(ReservationServiceID)
);
GO

-- Create ReservationServiceServiceBridge Table (Bridge between ReservationService and Service)
CREATE TABLE ReservationServiceServiceBridge (
    ReservationServiceID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (ReservationServiceID, ServiceID),
    CONSTRAINT FK_ReservationServiceServiceBridge_ReservationService FOREIGN KEY (ReservationServiceID) 
        REFERENCES ReservationService(ReservationServiceID),
    CONSTRAINT FK_ReservationServiceServiceBridge_Service FOREIGN KEY (ServiceID) 
        REFERENCES Service(ServiceID)
);
GO

-- Create LoyaltyProgram Table
CREATE TABLE LoyaltyProgram (
    LoyaltyID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT UNIQUE,
    MembershipLevel NVARCHAR(20) NOT NULL DEFAULT 'Bronze',
    ExpiryDate DATE NOT NULL,
    RewardPoints INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_LoyaltyProgram_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
GO

-- Create Payment Table
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    ReservationID INT,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentStatus NVARCHAR(20) NOT NULL,
    Discount DECIMAL(5,2) NULL,
    CONSTRAINT FK_Payment_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID),
    CONSTRAINT CK_Payment_Amount CHECK (Amount > 0)
);
GO

-- Create Feedback Table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    ReservationID INT UNIQUE,
    FeedbackDate DATETIME NOT NULL DEFAULT GETDATE(),
    Review NVARCHAR(MAX) NULL,
    Rating INT NOT NULL,
    CONSTRAINT FK_Feedback_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID),
    CONSTRAINT CK_Feedback_Rating CHECK (Rating BETWEEN 1 AND 5)
);
GO

-- =============================================
-- CREATE INDEXES WITH EXISTENCE CHECKS
-- =============================================

-- Function to check if an index exists and create it if it doesn't
IF OBJECT_ID('CreateIndexIfNotExists', 'P') IS NOT NULL
    DROP PROCEDURE CreateIndexIfNotExists;
GO

CREATE PROCEDURE CreateIndexIfNotExists
    @TableName NVARCHAR(128),
    @IndexName NVARCHAR(128),
    @ColumnList NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE name = @IndexName 
          AND object_id = OBJECT_ID(@TableName)
    )
    BEGIN
        DECLARE @SQL NVARCHAR(MAX) = N'CREATE INDEX ' + QUOTENAME(@IndexName) + 
                                     N' ON ' + @TableName + N'(' + @ColumnList + N')';
        EXEC sp_executesql @SQL;
    END
END;
GO

-- Create indexes using the procedure
EXEC CreateIndexIfNotExists 'Reservation', 'IX_Reservation_CustomerID', 'CustomerID';
EXEC CreateIndexIfNotExists 'Reservation', 'IX_Reservation_CheckInDate', 'CheckInDate';
EXEC CreateIndexIfNotExists 'Reservation', 'IX_Reservation_Status', 'Status';

EXEC CreateIndexIfNotExists 'ReservationService', 'IX_ReservationService_ServiceDate', 'ServiceDate';
EXEC CreateIndexIfNotExists 'ReservationService', 'IX_ReservationService_Status', 'Status';

EXEC CreateIndexIfNotExists 'ReservationReservationServiceBridge', 'IX_ReservationReservationServiceBridge_ReservationID', 'ReservationID';
EXEC CreateIndexIfNotExists 'ReservationReservationServiceBridge', 'IX_ReservationReservationServiceBridge_ReservationServiceID', 'ReservationServiceID';

EXEC CreateIndexIfNotExists 'StaffReservationServiceBridge', 'IX_StaffReservationServiceBridge_StaffID', 'StaffID';
EXEC CreateIndexIfNotExists 'StaffReservationServiceBridge', 'IX_StaffReservationServiceBridge_ReservationServiceID', 'ReservationServiceID';

EXEC CreateIndexIfNotExists 'ReservationServiceServiceBridge', 'IX_ReservationServiceServiceBridge_ReservationServiceID', 'ReservationServiceID';
EXEC CreateIndexIfNotExists 'ReservationServiceServiceBridge', 'IX_ReservationServiceServiceBridge_ServiceID', 'ServiceID';

EXEC CreateIndexIfNotExists 'StaffServiceBridge', 'IX_StaffServiceBridge_StaffID', 'StaffID';
EXEC CreateIndexIfNotExists 'StaffServiceBridge', 'IX_StaffServiceBridge_ServiceID', 'ServiceID';

EXEC CreateIndexIfNotExists 'FacilityServiceBridge', 'IX_FacilityServiceBridge_FacilityID', 'FacilityID';
EXEC CreateIndexIfNotExists 'FacilityServiceBridge', 'IX_FacilityServiceBridge_ServiceID', 'ServiceID';

EXEC CreateIndexIfNotExists 'Room', 'IX_Room_FacilityID', 'FacilityID';
EXEC CreateIndexIfNotExists 'Room', 'IX_Room_RoomType', 'RoomType';
EXEC CreateIndexIfNotExists 'Room', 'IX_Room_RoomStatus', 'RoomStatus';

EXEC CreateIndexIfNotExists 'Service', 'IX_Service_ServiceType', 'ServiceType';

EXEC CreateIndexIfNotExists 'Staff', 'IX_Staff_FacilityID', 'FacilityID';
EXEC CreateIndexIfNotExists 'Staff', 'IX_Staff_StaffRole', 'StaffRole';

EXEC CreateIndexIfNotExists 'Customer', 'IX_Customer_Email', 'CustomerEmail';
EXEC CreateIndexIfNotExists 'Customer', 'IX_Customer_LastName', 'CustLName';

EXEC CreateIndexIfNotExists 'ReferralSource', 'IX_ReferralSource_ReferrerType_ReferrerID', 'ReferrerType, ReferrerID';

-- Add index for ReferralSourceID in Affiliate table
EXEC CreateIndexIfNotExists 'Affiliate', 'IX_Affiliate_ReferralSourceID', 'ReferralSourceID';

-- Clean up the procedure
DROP PROCEDURE CreateIndexIfNotExists;
GO

-- Print success message with timestamp
DECLARE @CurrentTime DATETIME = GETDATE()
PRINT 'CanyonRanch database schema created successfully.'
PRINT 'Completion time: ' + CONVERT(VARCHAR, @CurrentTime, 126)
GO
