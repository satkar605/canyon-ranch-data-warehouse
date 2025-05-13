-- Canyon Ranch Database Sample Data Script
-- This script populates the CanyonRanch database with sample data
-- Last Updated: 2025-04-28

USE CanyonRanch;
GO

-- Clean database before inserting new data
PRINT 'Clearing existing data...';
DELETE FROM Feedback;
DELETE FROM Payment;
DELETE FROM LoyaltyProgram;
DELETE FROM StaffReservationServiceBridge;
DELETE FROM ReservationServiceServiceBridge;
DELETE FROM ReservationReservationServiceBridge;
DELETE FROM StaffServiceBridge;
DELETE FROM FacilityServiceBridge;
DELETE FROM ReservationService;
DELETE FROM Room;
DELETE FROM Reservation;
DELETE FROM Service;
DELETE FROM Staff;
DELETE FROM ProgramCoordinator;
DELETE FROM Affiliate;
DELETE FROM ReferralSource;
DELETE FROM Customer;
DELETE FROM Facility;
GO

-- Reset identity columns with explicit values (only for tables with identity columns)
PRINT 'Resetting identity columns...';
DBCC CHECKIDENT ('ReferralSource', RESEED, 0);
DBCC CHECKIDENT ('Feedback', RESEED, 0);
DBCC CHECKIDENT ('Payment', RESEED, 0);
DBCC CHECKIDENT ('LoyaltyProgram', RESEED, 0);
DBCC CHECKIDENT ('ReservationService', RESEED, 0);
DBCC CHECKIDENT ('Room', RESEED, 0);
DBCC CHECKIDENT ('Reservation', RESEED, 0);
DBCC CHECKIDENT ('Service', RESEED, 0);
DBCC CHECKIDENT ('Staff', RESEED, 0);
DBCC CHECKIDENT ('ProgramCoordinator', RESEED, 0);
DBCC CHECKIDENT ('Affiliate', RESEED, 0);
DBCC CHECKIDENT ('Customer', RESEED, 0);
DBCC CHECKIDENT ('Facility', RESEED, 0);
GO

-- Step 1: Insert root/parent tables first and capture their IDs
PRINT 'Inserting Facility data...';
INSERT INTO Facility (FacilityName, FacilityType, Address, Phone, OperatingHours)
VALUES 
    ('Canyon Ranch Tucson', 'Destination Spa', '8600 E Rockcliff Rd, Tucson, AZ 85750', '520-749-9000', '24/7'),
    ('Canyon Ranch Lenox', 'Destination Spa', '165 Kemble St, Lenox, MA 01240', '413-637-4100', '24/7'),
    ('SpaClub Venetian', 'Spa Club', '3355 Las Vegas Blvd S, Las Vegas, NV 89109', '702-414-3600', '6:00 AM - 8:00 PM'),
    ('SpaClub Gaylord Palms', 'Spa Club', '6000 W Osceola Pkwy, Kissimmee, FL 34746', '407-586-4772', '7:00 AM - 9:00 PM'),
    ('SpaClub Queen Mary II', 'Spa Club', 'Queen Mary 2, Cunard Line', '888-523-7472', '8:00 AM - 8:00 PM');
PRINT 'Facility data inserted. Count: 5';

-- Create variables to store facility IDs
DECLARE @FacilityID_Tucson INT, @FacilityID_Lenox INT, @FacilityID_Venetian INT, 
        @FacilityID_Gaylord INT, @FacilityID_QueenMary INT;
        
SELECT @FacilityID_Tucson = FacilityID FROM Facility WHERE FacilityName = 'Canyon Ranch Tucson';
SELECT @FacilityID_Lenox = FacilityID FROM Facility WHERE FacilityName = 'Canyon Ranch Lenox';
SELECT @FacilityID_Venetian = FacilityID FROM Facility WHERE FacilityName = 'SpaClub Venetian';
SELECT @FacilityID_Gaylord = FacilityID FROM Facility WHERE FacilityName = 'SpaClub Gaylord Palms';
SELECT @FacilityID_QueenMary = FacilityID FROM Facility WHERE FacilityName = 'SpaClub Queen Mary II';

PRINT 'Inserting Customer data...';
INSERT INTO Customer (CustFName, CustLName, CustMName, CustomerEmail, CustomerPhone, CustomerAddress, Gender, DateOfBirth, Preferences, MedicalHistory, ReferralCount, VisitCount)
VALUES
    ('John', 'Smith', NULL, 'john.smith@email.com', '555-123-4567', '123 Main St, Boston, MA 02108', 'Male', '1975-06-15', 'Vegetarian, Morning Yoga', 'Hypertension', 2, 5),
    ('Emily', 'Johnson', 'Rose', 'emily.johnson@email.com', '555-234-5678', '456 Oak Ave, Chicago, IL 60611', 'Female', '1982-09-23', 'Gluten-free, Pilates', 'None', 0, 3),
    ('Michael', 'Williams', 'James', 'michael.williams@email.com', '555-345-6789', '789 Pine Rd, San Francisco, CA 94109', 'Male', '1968-03-12', 'Low-sodium, Meditation', 'Type 2 Diabetes', 1, 4),
    ('Jennifer', 'Brown', NULL, 'jennifer.brown@email.com', '555-456-7890', '101 Cedar Ln, Denver, CO 80202', 'Female', '1990-11-05', 'Vegan, Hot Stone Massage', 'Asthma', 0, 2),
    ('Robert', 'Jones', 'Thomas', 'robert.jones@email.com', '555-567-8901', '202 Elm St, Seattle, WA 98101', 'Male', '1972-08-30', 'Early Riser, Hiking', 'None', 3, 6);
PRINT 'Customer data inserted. Count: 5';

-- Create variables for customer IDs
DECLARE @CustomerID1 INT, @CustomerID2 INT, @CustomerID3 INT, @CustomerID4 INT, @CustomerID5 INT;
SELECT @CustomerID1 = CustomerID FROM Customer WHERE CustomerEmail = 'john.smith@email.com';
SELECT @CustomerID2 = CustomerID FROM Customer WHERE CustomerEmail = 'emily.johnson@email.com';
SELECT @CustomerID3 = CustomerID FROM Customer WHERE CustomerEmail = 'michael.williams@email.com';
SELECT @CustomerID4 = CustomerID FROM Customer WHERE CustomerEmail = 'jennifer.brown@email.com';
SELECT @CustomerID5 = CustomerID FROM Customer WHERE CustomerEmail = 'robert.jones@email.com';

PRINT 'Inserting ReferralSource data...';
INSERT INTO ReferralSource (CustomerID, ReferrerType, ReferrerID)
VALUES
    (@CustomerID1, 'Affiliate', NULL),
    (@CustomerID2, 'Customer', @CustomerID1),
    (@CustomerID3, 'Affiliate', NULL);
PRINT 'ReferralSource data inserted. Count: 3';

-- Create variables for referral source IDs
DECLARE @ReferralSourceID1 INT, @ReferralSourceID2 INT, @ReferralSourceID3 INT;
SELECT @ReferralSourceID1 = ReferralSourceID FROM ReferralSource WHERE CustomerID = @CustomerID1;
SELECT @ReferralSourceID2 = ReferralSourceID FROM ReferralSource WHERE CustomerID = @CustomerID2;
SELECT @ReferralSourceID3 = ReferralSourceID FROM ReferralSource WHERE CustomerID = @CustomerID3;

PRINT 'Inserting Affiliate data...';
INSERT INTO Affiliate (AffiliateName, AffiliateContact, ReferralCount, ReferralSourceID)
VALUES
    ('Wellness Travel Agency', 'contact@wellnesstravel.com', 12, @ReferralSourceID1),
    ('Corporate Wellness Solutions', 'partners@corpwellness.com', 8, NULL),
    ('Luxury Spa Magazine', 'marketing@luxuryspa.com', 10, @ReferralSourceID3);
PRINT 'Affiliate data inserted. Count: 3';

-- Create variables for affiliate IDs
DECLARE @AffiliateID1 INT, @AffiliateID2 INT, @AffiliateID3 INT;
SELECT @AffiliateID1 = AffiliateID FROM Affiliate WHERE AffiliateName = 'Wellness Travel Agency';
SELECT @AffiliateID2 = AffiliateID FROM Affiliate WHERE AffiliateName = 'Corporate Wellness Solutions';
SELECT @AffiliateID3 = AffiliateID FROM Affiliate WHERE AffiliateName = 'Luxury Spa Magazine';

-- Step 2: Insert tables with foreign keys to parent tables
PRINT 'Inserting Program Coordinator data...';
INSERT INTO ProgramCoordinator (PCFName, PCLName, PCMName, PCEmail, PCPhone, AssignedReservations, ShiftSchedule, FacilityID)
VALUES
    ('Jessica', 'Patel', NULL, 'jessica.patel@canyonranch.com', '520-749-9001', 8, 'Mon-Fri: 8am-4pm', @FacilityID_Tucson),
    ('Marcus', 'Rivera', 'Luis', 'marcus.rivera@canyonranch.com', '520-749-9002', 6, 'Wed-Sun: 10am-6pm', @FacilityID_Tucson),
    ('Elizabeth', 'Wong', 'Kim', 'elizabeth.wong@canyonranch.com', '413-637-4101', 9, 'Mon-Fri: 9am-5pm', @FacilityID_Lenox);
PRINT 'Program Coordinator data inserted. Count: 3';

-- Create variables for PC IDs
DECLARE @PCID1 INT, @PCID2 INT, @PCID3 INT;
SELECT @PCID1 = PCID FROM ProgramCoordinator WHERE PCEmail = 'jessica.patel@canyonranch.com';
SELECT @PCID2 = PCID FROM ProgramCoordinator WHERE PCEmail = 'marcus.rivera@canyonranch.com';
SELECT @PCID3 = PCID FROM ProgramCoordinator WHERE PCEmail = 'elizabeth.wong@canyonranch.com';

PRINT 'Inserting Staff data...';
INSERT INTO Staff (StaffFName, StaffLName, StaffMName, StaffRole, Specialty, Availability, FacilityID)
VALUES
    ('Alex', 'Thompson', NULL, 'Massage Therapist', 'Deep Tissue', 'Mon-Fri: 9am-5pm', @FacilityID_Tucson),
    ('Maria', 'Gonzalez', 'Elena', 'Yoga Instructor', 'Vinyasa', 'Tue-Sat: 7am-3pm', @FacilityID_Tucson),
    ('Thomas', 'Nguyen', NULL, 'Nutritionist', 'Weight Management', 'Mon-Thu: 8am-6pm', @FacilityID_Lenox),
    ('Derek', 'Williams', 'James', 'Massage Therapist', 'Swedish', 'Mon-Fri: 10am-6pm', @FacilityID_Venetian),
    ('Priya', 'Sharma', NULL, 'Esthetician', 'Facials', 'Tue-Sat: 9am-5pm', @FacilityID_Gaylord);
PRINT 'Staff data inserted. Count: 5';

-- Create variables for staff IDs
DECLARE @StaffID1 INT, @StaffID2 INT, @StaffID3 INT, @StaffID4 INT, @StaffID5 INT;
SELECT @StaffID1 = StaffID FROM Staff WHERE StaffFName = 'Alex' AND StaffLName = 'Thompson';
SELECT @StaffID2 = StaffID FROM Staff WHERE StaffFName = 'Maria' AND StaffLName = 'Gonzalez';
SELECT @StaffID3 = StaffID FROM Staff WHERE StaffFName = 'Thomas' AND StaffLName = 'Nguyen';
SELECT @StaffID4 = StaffID FROM Staff WHERE StaffFName = 'Derek' AND StaffLName = 'Williams';
SELECT @StaffID5 = StaffID FROM Staff WHERE StaffFName = 'Priya' AND StaffLName = 'Sharma';

PRINT 'Inserting Service data...';
INSERT INTO Service (ServiceName, ServiceType, Description, Duration, Price, Capacity)
VALUES
    ('Deep Tissue Massage', 'Massage', 'Therapeutic massage targeting deeper muscle layers', 60, 150.00, 1),
    ('Hot Stone Massage', 'Massage', 'Relaxing massage using heated basalt stones', 90, 195.00, 1),
    ('Vinyasa Flow Yoga', 'Wellness', 'Dynamic yoga class linking breath with movement', 60, 45.00, 8),
    ('Nutrition Consultation', 'Wellness', 'Personalized nutrition plan with a certified nutritionist', 60, 125.00, 1),
    ('Signature Facial', 'Spa', 'Customized facial treatment for your skin type', 60, 140.00, 1);
PRINT 'Service data inserted. Count: 5';

-- Create variables for service IDs
DECLARE @ServiceID1 INT, @ServiceID2 INT, @ServiceID3 INT, @ServiceID4 INT, @ServiceID5 INT;
SELECT @ServiceID1 = ServiceID FROM Service WHERE ServiceName = 'Deep Tissue Massage';
SELECT @ServiceID2 = ServiceID FROM Service WHERE ServiceName = 'Hot Stone Massage';
SELECT @ServiceID3 = ServiceID FROM Service WHERE ServiceName = 'Vinyasa Flow Yoga';
SELECT @ServiceID4 = ServiceID FROM Service WHERE ServiceName = 'Nutrition Consultation';
SELECT @ServiceID5 = ServiceID FROM Service WHERE ServiceName = 'Signature Facial';

PRINT 'Inserting FacilityServiceBridge relationship (Facility-Service)...';
INSERT INTO FacilityServiceBridge (FacilityID, ServiceID)
VALUES
    (@FacilityID_Tucson, @ServiceID1), (@FacilityID_Tucson, @ServiceID2), 
    (@FacilityID_Tucson, @ServiceID3), (@FacilityID_Tucson, @ServiceID4), 
    (@FacilityID_Tucson, @ServiceID5),
    (@FacilityID_Lenox, @ServiceID1), (@FacilityID_Lenox, @ServiceID2), 
    (@FacilityID_Lenox, @ServiceID3), (@FacilityID_Lenox, @ServiceID4),
    (@FacilityID_Venetian, @ServiceID1), (@FacilityID_Venetian, @ServiceID2), 
    (@FacilityID_Venetian, @ServiceID5),
    (@FacilityID_Gaylord, @ServiceID1), (@FacilityID_Gaylord, @ServiceID5),
    (@FacilityID_QueenMary, @ServiceID1), (@FacilityID_QueenMary, @ServiceID2);
PRINT 'FacilityServiceBridge relationships inserted. Count: 16';

PRINT 'Inserting StaffServiceBridge relationship (Staff-Service)...';
INSERT INTO StaffServiceBridge (StaffID, ServiceID)
VALUES
    (@StaffID1, @ServiceID1), (@StaffID1, @ServiceID2),  -- Alex is qualified for massages
    (@StaffID2, @ServiceID3),          -- Maria is qualified for yoga
    (@StaffID3, @ServiceID4),          -- Thomas is qualified for nutrition
    (@StaffID4, @ServiceID1), (@StaffID4, @ServiceID2),  -- Derek is qualified for massages
    (@StaffID5, @ServiceID5);          -- Priya is qualified for facials
PRINT 'StaffServiceBridge relationships inserted. Count: 7';

PRINT 'Inserting Room data...';
INSERT INTO Room (FacilityID, RoomType, RoomRate, Capacity, RoomStatus, Amenities)
VALUES
    (@FacilityID_Tucson, 'Deluxe King', 450.00, 2, 'Available', 'Mountain view, Balcony, Organic linens'),
    (@FacilityID_Tucson, 'Executive Suite', 675.00, 2, 'Available', 'Living area, Soaking tub, Desert view'),
    (@FacilityID_Lenox, 'Berkshire Suite', 695.00, 2, 'Available', 'Fireplace, Forest view, Soaking tub'),
    (@FacilityID_Lenox, 'Deluxe King', 475.00, 2, 'Available', 'Luxury linens, Garden view, Rainfall shower');
PRINT 'Room data inserted. Count: 4';

-- Create variables for room IDs
DECLARE @RoomID1 INT, @RoomID2 INT, @RoomID3 INT, @RoomID4 INT;
SELECT @RoomID1 = RoomID FROM Room WHERE FacilityID = @FacilityID_Tucson AND RoomType = 'Deluxe King';
SELECT @RoomID2 = RoomID FROM Room WHERE FacilityID = @FacilityID_Tucson AND RoomType = 'Executive Suite';
SELECT @RoomID3 = RoomID FROM Room WHERE FacilityID = @FacilityID_Lenox AND RoomType = 'Berkshire Suite';
SELECT @RoomID4 = RoomID FROM Room WHERE FacilityID = @FacilityID_Lenox AND RoomType = 'Deluxe King';

-- Step 3: Insert tables that depend on multiple parent tables
PRINT 'Inserting Reservation data...';
INSERT INTO Reservation (CustomerID, ReservationDate, CheckInDate, CheckOutDate, ReservationType, SpecialRequests, NoOfGuests, Status, PCID)
VALUES
    (@CustomerID1, '2023-02-15', '2023-03-10', '2023-03-15', 'Stay', 'Early check-in if possible', 1, 'Completed', @PCID1),
    (@CustomerID2, '2023-03-01', '2023-04-05', '2023-04-12', 'Stay', 'Room away from elevator', 2, 'Completed', @PCID3),
    (@CustomerID3, '2023-03-20', '2023-05-15', '2023-05-20', 'Day Visit', NULL, 1, 'Completed', @PCID2);
PRINT 'Reservation data inserted. Count: 3';

-- Create variables for reservation IDs
DECLARE @ReservationID1 INT, @ReservationID2 INT, @ReservationID3 INT;
SELECT @ReservationID1 = ReservationID FROM Reservation WHERE CustomerID = @CustomerID1;
SELECT @ReservationID2 = ReservationID FROM Reservation WHERE CustomerID = @CustomerID2;
SELECT @ReservationID3 = ReservationID FROM Reservation WHERE CustomerID = @CustomerID3;

PRINT 'Inserting ReservationService data...';
INSERT INTO ReservationService (ServiceDate, TimeSlot, Status, Notes, Price)
VALUES
    ('2023-03-11', '10:00:00', 'Completed', 'Client requested extra focus on shoulders', 150.00),
    ('2023-03-12', '08:00:00', 'Completed', NULL, 45.00),
    ('2023-04-06', '09:00:00', 'Completed', NULL, 195.00),
    ('2023-05-16', '10:00:00', 'Completed', 'First-time client', 125.00);
PRINT 'ReservationService data inserted. Count: 4';

-- Create variables for reservation service IDs
DECLARE @ReservationServiceID1 INT, @ReservationServiceID2 INT, 
        @ReservationServiceID3 INT, @ReservationServiceID4 INT;
        
SELECT TOP 1 @ReservationServiceID1 = ReservationServiceID 
FROM ReservationService 
WHERE ServiceDate = '2023-03-11' AND TimeSlot = '10:00:00';

SELECT TOP 1 @ReservationServiceID2 = ReservationServiceID 
FROM ReservationService 
WHERE ServiceDate = '2023-03-12' AND TimeSlot = '08:00:00';

SELECT TOP 1 @ReservationServiceID3 = ReservationServiceID 
FROM ReservationService 
WHERE ServiceDate = '2023-04-06' AND TimeSlot = '09:00:00';

SELECT TOP 1 @ReservationServiceID4 = ReservationServiceID 
FROM ReservationService 
WHERE ServiceDate = '2023-05-16' AND TimeSlot = '10:00:00';

PRINT 'Inserting ReservationReservationServiceBridge relationship (Reservation-ReservationService)...';
INSERT INTO ReservationReservationServiceBridge (ReservationID, ReservationServiceID)
VALUES
    (@ReservationID1, @ReservationServiceID1), 
    (@ReservationID1, @ReservationServiceID2),  -- First reservation includes services 1 and 2
    (@ReservationID2, @ReservationServiceID3),  -- Second reservation includes service 3
    (@ReservationID3, @ReservationServiceID4);  -- Third reservation includes service 4
PRINT 'ReservationReservationServiceBridge relationships inserted. Count: 4';

PRINT 'Inserting StaffReservationServiceBridge relationship (Staff-ReservationService)...';
INSERT INTO StaffReservationServiceBridge (StaffID, ReservationServiceID)
VALUES
    (@StaffID1, @ReservationServiceID1),  -- Alex is assigned to service 1
    (@StaffID2, @ReservationServiceID2),  -- Maria is assigned to service 2
    (@StaffID4, @ReservationServiceID3),  -- Derek is assigned to service 3
    (@StaffID3, @ReservationServiceID4);  -- Thomas is assigned to service 4
PRINT 'StaffReservationServiceBridge relationships inserted. Count: 4';

PRINT 'Inserting ReservationServiceServiceBridge relationship (ReservationService-Service)...';
INSERT INTO ReservationServiceServiceBridge (ReservationServiceID, ServiceID)
VALUES
    (@ReservationServiceID1, @ServiceID1),  -- ReservationService 1 refers to Deep Tissue Massage
    (@ReservationServiceID2, @ServiceID3),  -- ReservationService 2 refers to Yoga
    (@ReservationServiceID3, @ServiceID2),  -- ReservationService 3 refers to Hot Stone Massage
    (@ReservationServiceID4, @ServiceID4);  -- ReservationService 4 refers to Nutrition Consultation
PRINT 'ReservationServiceServiceBridge relationships inserted. Count: 4';

PRINT 'Inserting LoyaltyProgram data...';
INSERT INTO LoyaltyProgram (CustomerID, MembershipLevel, ExpiryDate, RewardPoints)
VALUES
    (@CustomerID1, 'Gold', '2025-12-31', 2500),
    (@CustomerID2, 'Silver', '2025-12-31', 1200),
    (@CustomerID3, 'Bronze', '2025-12-31', 750);
PRINT 'LoyaltyProgram data inserted. Count: 3';

PRINT 'Inserting Payment data...';
INSERT INTO Payment (ReservationID, Amount, PaymentMethod, PaymentDate, PaymentStatus, Discount)
VALUES
    (@ReservationID1, 1245.00, 'Credit Card', '2023-02-15', 'Completed', 10.00),
    (@ReservationID2, 2350.00, 'Credit Card', '2023-03-01', 'Completed', NULL),
    (@ReservationID3, 125.00, 'PayPal', '2023-03-20', 'Completed', 5.00);
PRINT 'Payment data inserted. Count: 3';

PRINT 'Inserting Feedback data...';
INSERT INTO Feedback (ReservationID, FeedbackDate, Review, Rating)
VALUES
    (@ReservationID1, '2023-03-16', 'Excellent facilities and attentive staff. The massage was outstanding.', 5),
    (@ReservationID2, '2023-04-13', 'Very relaxing stay. The hot stone treatment was transformative.', 4);
PRINT 'Feedback data inserted. Count: 2';

-- Print final status with timestamp
DECLARE @TotalCount INT = 0;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Facility;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Customer;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Affiliate;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM ReferralSource;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM ProgramCoordinator;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Staff;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Service;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM FacilityServiceBridge;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM StaffServiceBridge;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Room;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Reservation;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM ReservationService;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM ReservationReservationServiceBridge;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM StaffReservationServiceBridge;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM ReservationServiceServiceBridge;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM LoyaltyProgram;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Payment;
SELECT @TotalCount = @TotalCount + COUNT(*) FROM Feedback;

PRINT '----------------------------------------------';
PRINT 'CanyonRanch database populated successfully!';
PRINT 'Total records inserted: ' + CAST(@TotalCount AS VARCHAR(10));
PRINT 'Completion time: ' + CONVERT(VARCHAR(30), GETDATE(), 126);
PRINT '----------------------------------------------';
GO