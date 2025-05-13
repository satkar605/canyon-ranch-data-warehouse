-- Canyon Ranch Data Warehouse Population Script
-- Last Updated: 2025-04-30 - Updated to populate derived metrics for ratings and usage counts

USE CanyonRanch;
GO

-- Step 1: Populate Dim_Date with a range of dates
INSERT INTO CanyonRanch.DW.Dim_Date (DateKey, FullDate, DayOfWeek, DayName, Month, MonthName, Quarter, Year)
SELECT 
    CONVERT(INT, CONVERT(VARCHAR, Calendar.Date, 112)) AS DateKey,
    Calendar.Date AS FullDate,
    DATEPART(WEEKDAY, Calendar.Date) AS DayOfWeek,
    DATENAME(WEEKDAY, Calendar.Date) AS DayName,
    DATEPART(MONTH, Calendar.Date) AS Month,
    DATENAME(MONTH, Calendar.Date) AS MonthName,
    DATEPART(QUARTER, Calendar.Date) AS Quarter,
    DATEPART(YEAR, Calendar.Date) AS Year
FROM (
    SELECT TOP (1096) -- 3 years of dates
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY object_id) - 1, '2023-01-01') AS Date
    FROM sys.all_objects
) AS Calendar;
PRINT 'Populated Dim_Date with 3 years of dates.';

-- Step 2: Populate Dim_ServiceType initially without derived metrics
INSERT INTO CanyonRanch.DW.Dim_ServiceType (ServiceTypeName)
SELECT DISTINCT 
    ServiceType AS ServiceTypeName
FROM 
    CanyonRanch.dbo.Service;
PRINT 'Populated Dim_ServiceType with distinct service types.';

-- Step 3: Populate Dim_Customer from Customer table
INSERT INTO CanyonRanch.DW.Dim_Customer (CustomerID, CustomerName, Gender, AgeGroup, LoyaltyLevel)
SELECT 
    c.CustomerID,
    c.CustFName + ' ' + c.CustLName AS CustomerName,
    c.Gender,
    CASE 
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 30 THEN 'Under 30'
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 50 THEN '30-49'
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 70 THEN '50-69'
        ELSE '70+' 
    END AS AgeGroup,
    COALESCE(l.MembershipLevel, 'None') AS LoyaltyLevel
FROM 
    CanyonRanch.dbo.Customer c
LEFT JOIN 
    CanyonRanch.dbo.LoyaltyProgram l ON c.CustomerID = l.CustomerID;
PRINT 'Populated Dim_Customer with customer data.';

-- Step 4: Populate Dim_Service from Service table (initially without derived metrics)
INSERT INTO CanyonRanch.DW.Dim_Service (ServiceID, ServiceName, ServiceTypeKey, Duration, Price)
SELECT 
    s.ServiceID, 
    s.ServiceName, 
    st.ServiceTypeKey, 
    s.Duration, 
    s.Price
FROM 
    CanyonRanch.dbo.Service s
JOIN 
    CanyonRanch.DW.Dim_ServiceType st ON s.ServiceType = st.ServiceTypeName;
PRINT 'Populated Dim_Service with service data, linked to Dim_ServiceType.';

-- Step 5: Populate Fact_ReservationService with service booking facts
INSERT INTO CanyonRanch.DW.Fact_ReservationService (
    DateKey, CustomerKey, ServiceKey, ServiceDate, TimeSlot, 
    Revenue, ServiceCount, ServiceDurationMinutes, ServiceRevenueAmount
)
SELECT 
    -- Get DateKey by joining to Dim_Date
    dd.DateKey,
    
    -- Join to Dim_Customer for the surrogate key
    dc.CustomerKey,
    
    -- Join to Dim_Service for the surrogate key
    ds.ServiceKey,
    
    rs.ServiceDate,
    rs.TimeSlot,
    s.Price AS Revenue,
    1 AS ServiceCount, -- Each row represents 1 service
    s.Duration AS ServiceDurationMinutes,
    s.Price AS ServiceRevenueAmount
FROM 
    CanyonRanch.dbo.ReservationService rs
JOIN 
    CanyonRanch.dbo.ReservationServiceServiceBridge rssb ON rs.ReservationServiceID = rssb.ReservationServiceID
JOIN 
    CanyonRanch.dbo.Service s ON rssb.ServiceID = s.ServiceID
JOIN 
    CanyonRanch.dbo.ReservationReservationServiceBridge rrsb ON rs.ReservationServiceID = rrsb.ReservationServiceID
JOIN 
    CanyonRanch.dbo.Reservation r ON rrsb.ReservationID = r.ReservationID
JOIN 
    CanyonRanch.dbo.Customer c ON r.CustomerID = c.CustomerID
JOIN
    CanyonRanch.DW.Dim_Customer dc ON c.CustomerID = dc.CustomerID
JOIN
    CanyonRanch.DW.Dim_Service ds ON s.ServiceID = ds.ServiceID
JOIN
    CanyonRanch.DW.Dim_Date dd ON dd.FullDate = rs.ServiceDate;
PRINT 'Populated Fact_ReservationService with booking data.';

-- Step 6: Update Dim_Service with average ratings from Feedback
UPDATE ds
SET AvgRating = subquery.AvgRating
FROM CanyonRanch.DW.Dim_Service ds
JOIN (
    SELECT 
        s.ServiceID,
        AVG(CAST(f.Rating AS DECIMAL(3,2))) AS AvgRating
    FROM 
        CanyonRanch.dbo.Service s
    JOIN 
        CanyonRanch.dbo.ReservationServiceServiceBridge rssb ON s.ServiceID = rssb.ServiceID
    JOIN 
        CanyonRanch.dbo.ReservationService rs ON rssb.ReservationServiceID = rs.ReservationServiceID
    JOIN 
        CanyonRanch.dbo.ReservationReservationServiceBridge rrsb ON rs.ReservationServiceID = rrsb.ReservationServiceID
    JOIN 
        CanyonRanch.dbo.Reservation r ON rrsb.ReservationID = r.ReservationID
    JOIN 
        CanyonRanch.dbo.Feedback f ON r.ReservationID = f.ReservationID
    GROUP BY 
        s.ServiceID
) subquery ON ds.ServiceID = subquery.ServiceID;
PRINT 'Updated Dim_Service with average ratings from Feedback.';

-- Step 7: Update Dim_ServiceType with usage counts
UPDATE dst
SET ServiceUsageCount = subquery.ServiceCount
FROM CanyonRanch.DW.Dim_ServiceType dst
JOIN (
    SELECT 
        st.ServiceTypeKey,
        COUNT(f.ReservationServiceKey) AS ServiceCount
    FROM 
        CanyonRanch.DW.Dim_ServiceType st
    JOIN 
        CanyonRanch.DW.Dim_Service s ON st.ServiceTypeKey = s.ServiceTypeKey
    JOIN 
        CanyonRanch.DW.Fact_ReservationService f ON s.ServiceKey = f.ServiceKey
    GROUP BY 
        st.ServiceTypeKey
) subquery ON dst.ServiceTypeKey = subquery.ServiceTypeKey;
PRINT 'Updated Dim_ServiceType with service usage counts.';

-- Step 8: Update Dim_ServiceType with average type ratings derived from Dim_Service
UPDATE dst
SET AvgTypeRating = subquery.AvgRating
FROM CanyonRanch.DW.Dim_ServiceType dst
JOIN (
    SELECT 
        s.ServiceTypeKey,
        AVG(s.AvgRating) AS AvgRating
    FROM 
        CanyonRanch.DW.Dim_Service s
    WHERE
        s.AvgRating IS NOT NULL
    GROUP BY 
        s.ServiceTypeKey
) subquery ON dst.ServiceTypeKey = subquery.ServiceTypeKey;
PRINT 'Updated Dim_ServiceType with average type ratings.';

PRINT '----------------------------------------------';
PRINT 'Data warehouse population complete!';
PRINT 'All dimension and fact tables populated';
PRINT 'Derived metrics calculated and updated';
PRINT 'Completion time: ' + CONVERT(VARCHAR, GETDATE(), 126);
PRINT '----------------------------------------------';
GO
