# Canyon Ranch Database - Comprehensive Data Dictionary

This document outlines the SQL Server schema design decisions for the Canyon Ranch database, including the data types, constraints, and relationships for each entity.

## Main Entities

### 1. Customer
**Description**: Stores all personal and contact information about customers who visit Canyon Ranch.

| Column Name     | Data Type      | Constraints                | Description                                 |
|-----------------|----------------|----------------------------|---------------------------------------------|
| CustomerID      | INT            | PRIMARY KEY, IDENTITY      | Unique identifier for each customer         |
| CustFName       | NVARCHAR(50)   | NOT NULL                   | Customer's first name                       |
| CustLName       | NVARCHAR(50)   | NOT NULL                   | Customer's last name                        |
| CustMName       | NVARCHAR(50)   | NULL                       | Customer's middle name, if available        |
| CustomerEmail   | NVARCHAR(320)  | UNIQUE, NOT NULL           | Customer's email address for communications |
| CustomerPhone   | NVARCHAR(15)   | NOT NULL                   | Customer's primary contact phone number     |
| CustomerAddress | NVARCHAR(255)  | NOT NULL                   | Full residential or mailing address         |
| Gender          | NVARCHAR(20)   | NULL                       | Customer's gender, if provided              |
| DateOfBirth     | DATE           | NOT NULL                   | Customer's birth date                       |
| Preferences     | NVARCHAR(MAX)  | NULL                       | JSON string of customer preferences         |
| MedicalHistory  | NVARCHAR(MAX)  | NULL                       | Medical conditions and notes                |
| ReferralCount   | INT            | DEFAULT 0                  | Number of referrals made by this customer   |
| VisitCount      | INT            | DEFAULT 0                  | Number of visits to Canyon Ranch facilities |

### 2. Reservation
**Description**: Tracks all bookings made by customers, including dates, types, and status.

| Column Name      | Data Type      | Constraints                | Description                               |
|------------------|----------------|----------------------------|-------------------------------------------|
| ReservationID    | INT            | PRIMARY KEY, IDENTITY      | Unique identifier for each reservation    |
| CustomerID       | INT            | FOREIGN KEY                | References the customer making reservation|
| ReservationDate  | DATETIME       | NOT NULL, DEFAULT GETDATE()| Date and time when reservation was made   |
| CheckInDate      | DATE           | NOT NULL                   | Expected arrival/check-in date            |
| CheckOutDate     | DATE           | NOT NULL                   | Expected departure/check-out date         |
| ReservationType  | NVARCHAR(50)   | NOT NULL                   | Type of reservation (Stay, Day Visit)     |
| SpecialRequests  | NVARCHAR(MAX)  | NULL                       | Any special requirements noted by customer|
| NoOfGuests       | INT            | NOT NULL, DEFAULT 1        | Number of guests included in reservation  |
| Status           | NVARCHAR(20)   | NOT NULL, DEFAULT 'Pending'| Current status of the reservation         |
| PCID             | INT            | FOREIGN KEY                | Program Coordinator managing reservation  |

### 3. Service
**Description**: Catalogs all services offered across Canyon Ranch facilities.

| Column Name | Data Type      | Constraints           | Description                            |
|-------------|----------------|----------------------|----------------------------------------|
| ServiceID   | INT            | PRIMARY KEY, IDENTITY | Unique identifier for each service     |
| ServiceName | NVARCHAR(100)  | NOT NULL             | Name of the service offering           |
| ServiceType | NVARCHAR(50)   | NOT NULL             | Category or type of service            |
| Description | NVARCHAR(MAX)  | NULL                 | Detailed description of the service    |
| Duration    | INT            | NOT NULL             | Duration of the service in minutes     |
| Price       | DECIMAL(10,2)  | NOT NULL             | Standard cost of the service           |
| Capacity    | INT            | NOT NULL             | Maximum number of participants allowed |

### 4. ReservationService
**Description**: Tracks individual service bookings within reservations.

| Column Name          | Data Type      | Constraints                | Description                              |
|----------------------|----------------|----------------------------|------------------------------------------|
| ReservationServiceID | INT            | PRIMARY KEY, IDENTITY      | Unique identifier for reserved service   |
| ServiceDate          | DATE           | NOT NULL                   | Date when service is scheduled           |
| TimeSlot             | TIME(7)        | NOT NULL                   | Time when service is scheduled           |
| Status               | NVARCHAR(20)   | NOT NULL, DEFAULT 'Booked' | Status of service booking                |
| Notes                | NVARCHAR(MAX)  | NULL                       | Additional notes about service booking   |
| Price                | DECIMAL(10,2)  | NOT NULL                   | Price for this specific service booking  |

### 5. Staff
**Description**: Maintains records of all employees and their specialties.

| Column Name   | Data Type      | Constraints           | Description                            |
|---------------|----------------|----------------------|----------------------------------------|
| StaffID       | INT            | PRIMARY KEY, IDENTITY | Unique identifier for staff member     |
| StaffFName    | NVARCHAR(50)   | NOT NULL             | Staff member's first name              |
| StaffLName    | NVARCHAR(50)   | NOT NULL             | Staff member's last name               |
| StaffMName    | NVARCHAR(50)   | NULL                 | Staff member's middle name, if any     |
| StaffRole     | NVARCHAR(50)   | NOT NULL             | Job role or position of staff member   |
| Specialty     | NVARCHAR(100)  | NULL                 | Staff member's area of expertise       |
| Availability  | NVARCHAR(MAX)  | NULL                 | Staff member's availability schedule   |
| FacilityID    | INT            | FOREIGN KEY          | Facility where staff member works      |

### 6. Program Coordinator
**Description**: Specialized staff who manage customer reservations.

| Column Name          | Data Type      | Constraints           | Description                            |
|----------------------|----------------|----------------------|----------------------------------------|
| PCID                 | INT            | PRIMARY KEY, IDENTITY | Unique identifier for coordinator       |
| PCFName              | NVARCHAR(50)   | NOT NULL             | Coordinator's first name               |
| PCLName              | NVARCHAR(50)   | NOT NULL             | Coordinator's last name                |
| PCMName              | NVARCHAR(50)   | NULL                 | Coordinator's middle name, if any      |
| PCEmail              | NVARCHAR(320)  | UNIQUE, NOT NULL     | Coordinator's email address            |
| PCPhone              | NVARCHAR(15)   | NOT NULL             | Coordinator's phone number             |
| AssignedReservations | INT            | DEFAULT 0            | Count of reservations assigned         |
| ShiftSchedule        | NVARCHAR(MAX)  | NULL                 | Work schedule information              |
| FacilityID           | INT            | FOREIGN KEY          | Facility where coordinator is assigned |

### 7. Facility
**Description**: Records all Canyon Ranch locations and operational details.

| Column Name         | Data Type      | Constraints           | Description                            |
|---------------------|----------------|----------------------|----------------------------------------|
| FacilityID          | INT            | PRIMARY KEY, IDENTITY | Unique identifier for facility          |
| FacilityName        | NVARCHAR(100)  | NOT NULL             | Name of the facility location          |
| FacilityType        | NVARCHAR(50)   | NOT NULL             | Type of facility (Resort, Spa, etc.)   |
| Address             | NVARCHAR(255)  | NOT NULL             | Physical address of the facility        |
| Phone               | NVARCHAR(15)   | NOT NULL             | Contact phone number for the facility   |
| OperatingHours      | NVARCHAR(MAX)  | NULL                 | Hours of operation for the facility     |

### 8. Room
**Description**: Catalogs all accommodations available at each facility.

| Column Name | Data Type      | Constraints                    | Description                           |
|-------------|----------------|--------------------------------|---------------------------------------|
| RoomID      | INT            | PRIMARY KEY, IDENTITY          | Unique identifier for room            |
| FacilityID  | INT            | FOREIGN KEY                    | Facility where room is located        |
| RoomType    | NVARCHAR(50)   | NOT NULL                       | Type of room (Standard, Suite, etc.)  |
| RoomRate    | DECIMAL(10,2)  | NOT NULL                       | Cost per night for the room           |
| Capacity    | INT            | NOT NULL                       | Maximum number of guests allowed      |
| RoomStatus  | NVARCHAR(20)   | NOT NULL, DEFAULT 'Available'  | Current status of room                |
| Amenities   | NVARCHAR(MAX)  | NULL                           | List of amenities available in room   |

### 9. LoyaltyProgram
**Description**: Manages the customer rewards system.

| Column Name     | Data Type     | Constraints                  | Description                           |
|-----------------|---------------|------------------------------|---------------------------------------|
| LoyaltyID       | INT           | PRIMARY KEY, IDENTITY        | Unique identifier for loyalty record  |
| CustomerID      | INT           | FOREIGN KEY, UNIQUE          | References customer in program        |
| MembershipLevel | NVARCHAR(20)  | NOT NULL, DEFAULT 'Bronze'   | Level in loyalty program              |
| ExpiryDate      | DATE          | NOT NULL                     | Date when membership expires          |
| RewardPoints    | INT           | NOT NULL, DEFAULT 0          | Number of points accumulated          |

### 10. Payment
**Description**: Records all financial transactions associated with reservations.

| Column Name    | Data Type      | Constraints                | Description                           |
|----------------|----------------|----------------------------|---------------------------------------|
| PaymentID      | INT            | PRIMARY KEY, IDENTITY      | Unique identifier for payment         |
| ReservationID  | INT            | FOREIGN KEY                | References associated reservation     |
| Amount         | DECIMAL(10,2)  | NOT NULL                   | Payment amount                        |
| PaymentMethod  | NVARCHAR(50)   | NOT NULL                   | Method of payment (Credit Card, etc.) |
| PaymentDate    | DATETIME       | NOT NULL, DEFAULT GETDATE()| Date and time when payment was made   |
| PaymentStatus  | NVARCHAR(20)   | NOT NULL                   | Status of payment (Completed, etc.)   |
| Discount       | DECIMAL(5,2)   | NULL                       | Discount percentage applied, if any   |

### 11. Feedback
**Description**: Captures customer reviews and ratings after their stay.

| Column Name   | Data Type      | Constraints                | Description                           |
|---------------|----------------|----------------------------|---------------------------------------|
| FeedbackID    | INT            | PRIMARY KEY, IDENTITY      | Unique identifier for feedback        |
| ReservationID | INT            | FOREIGN KEY, UNIQUE        | References associated reservation     |
| FeedbackDate  | DATETIME       | NOT NULL, DEFAULT GETDATE()| Date when feedback was provided       |
| Review        | NVARCHAR(MAX)  | NULL                       | Text of customer review               |
| Rating        | INT            | NOT NULL                   | Numerical rating (1-5)                |

### 12. ReferralSource
**Description**: Tracks how new customers discovered Canyon Ranch.

| Column Name      | Data Type      | Constraints           | Description                           |
|------------------|----------------|----------------------|---------------------------------------|
| ReferralSourceID | INT            | PRIMARY KEY, IDENTITY | Unique identifier for referral source |
| CustomerID       | INT            | FOREIGN KEY          | Customer being referred               |
| ReferrerType     | NVARCHAR(20)   | NOT NULL             | Type of referrer (Customer, Affiliate)|
| ReferrerID       | INT            | NULL                 | ID of the referring entity            |

### 13. Affiliate
**Description**: Maintains information about partner organizations.

| Column Name      | Data Type      | Constraints           | Description                           |
|------------------|----------------|----------------------|---------------------------------------|
| AffiliateID      | INT            | PRIMARY KEY, IDENTITY | Unique identifier for affiliate       |
| AffiliateName    | NVARCHAR(100)  | NOT NULL             | Name of the affiliate or partner      |
| AffiliateContact | NVARCHAR(100)  | NOT NULL             | Contact information for affiliate     |
| ReferralCount    | INT            | NOT NULL, DEFAULT 0   | Total number of referrals made        |
| ReferralSourceID | INT            | FOREIGN KEY          | References referral source record     |

## Bridge Tables

### 14. FacilityServiceBridge
**Description**: Maps which services are offered at each facility.

| Column Name | Data Type | Constraints                  | Description                        |
|-------------|-----------|------------------------------|------------------------------------|
| FacilityID  | INT       | PRIMARY KEY (composite part) | References the facility            |
| ServiceID   | INT       | PRIMARY KEY (composite part) | References the service             |

### 15. StaffServiceBridge
**Description**: Tracks which staff members are qualified to provide specific services.

| Column Name | Data Type | Constraints                  | Description                        |
|-------------|-----------|------------------------------|------------------------------------|
| StaffID     | INT       | PRIMARY KEY (composite part) | References the staff member        |
| ServiceID   | INT       | PRIMARY KEY (composite part) | References the service             |

### 16. ReservationReservationServiceBridge
**Description**: Links reservations to multiple reservation services.

| Column Name          | Data Type | Constraints                  | Description                        |
|----------------------|-----------|------------------------------|------------------------------------|
| ReservationID        | INT       | PRIMARY KEY (composite part) | References the reservation         |
| ReservationServiceID | INT       | PRIMARY KEY (composite part) | References the reservation service |

### 17. StaffReservationServiceBridge
**Description**: Assigns staff members to specific reservation services.

| Column Name          | Data Type | Constraints                   | Description                         |
|----------------------|-----------|-------------------------------|-------------------------------------|
| StaffID              | INT       | PRIMARY KEY (composite part)  | References the staff member         |
| ReservationServiceID | INT       | PRIMARY KEY (composite part)  | References the reservation service  |
| AssignedDate         | DATETIME  | NOT NULL, DEFAULT GETDATE()   | Date when assignment was made       |

### 18. ReservationServiceServiceBridge
**Description**: Connects reservation services to specific services.

| Column Name          | Data Type | Constraints                   | Description                         |
|----------------------|-----------|-------------------------------|-------------------------------------|
| ReservationServiceID | INT       | PRIMARY KEY (composite part)  | References the reservation service  |
| ServiceID            | INT       | PRIMARY KEY (composite part)  | References the service              |

## Data Warehouse Dictionary
This document provides a comprehensive reference for all tables and columns in the Canyon Ranch data warehouse, including data types, descriptions, and relationships between tables.

# Define the individual markdown tables for each data warehouse entity

**Fact_ReservationService**  
_Stores each instance of a booked service, supporting revenue and performance tracking._

| Column Name              | Data Type      | Constraints                | Description                                     | Source/Derived         |
|--------------------------|----------------|----------------------------|-------------------------------------------------|------------------------|
| ReservationServiceKey    | INT            | PRIMARY KEY, IDENTITY      | Surrogate identifier for each service booking   | Generated              |
| DateKey                  | INT            | FOREIGN KEY                | Reference to Dim_Date dimension                 | Join to Dim_Date       |
| CustomerKey              | INT            | FOREIGN KEY                | Reference to Dim_Customer dimension             | Join to Dim_Customer   |
| ServiceKey               | INT            | FOREIGN KEY                | Reference to Dim_Service dimension              | Join to Dim_Service    |
| ServiceDate              | DATE           | NOT NULL                   | Calendar date of the service                    | ReservationService     |
| TimeSlot                 | TIME(7)        | NOT NULL                   | Scheduled time of the service                   | ReservationService     |
| Revenue                  | DECIMAL(10,2)  | NOT NULL                   | Amount paid for the service                     | Service.Price          |
| ServiceCount             | INT            | NOT NULL, DEFAULT 1        | Count of services (always 1 for atomic grain)   | Derived (constant)     |
| ServiceDurationMinutes   | INT            | NOT NULL                   | Duration of service in minutes                  | Service.Duration       |
| ServiceRevenueAmount     | DECIMAL(10,2)  | NOT NULL                   | Duplicate of revenue for analysis flexibility   | Service.Price          |

**Dim_Date**  
_Provides temporal attributes for filtering and time-series analysis._

| Column Name   | Data Type     | Constraints       | Description                         | Source/Derived    |
|---------------|----------------|-------------------|-------------------------------------|-------------------|
| DateKey       | INT            | PRIMARY KEY       | Date in YYYYMMDD format             | Derived           |
| FullDate      | DATE           | NOT NULL, UNIQUE  | Actual calendar date                | Source            |
| DayOfWeek     | INT            | NOT NULL          | Day number (1=Sunday, 7=Saturday)   | Derived           |
| DayName       | NVARCHAR(10)   | NOT NULL          | Name of day                         | Derived           |
| Month         | INT            | NOT NULL          | Month number (1-12)                 | Derived           |
| MonthName     | NVARCHAR(10)   | NOT NULL          | Name of month                       | Derived           |
| Quarter       | INT            | NOT NULL          | Calendar quarter (1-4)              | Derived           |
| Year          | INT            | NOT NULL          | Calendar year                       | Derived           |

**Dim_Customer**  
_Stores enriched customer profiles for segmentation and demographic analysis._

| Column Name   | Data Type      | Constraints         | Description                             | Source/Derived       |
|---------------|----------------|----------------------|-----------------------------------------|----------------------|
| CustomerKey   | INT            | PRIMARY KEY, IDENTITY| Surrogate identifier for customer        | Generated             |
| CustomerID    | INT            | NOT NULL, UNIQUE     | Business key from source system         | Customer             |
| CustomerName  | NVARCHAR(100)  | NOT NULL             | Full name of customer                   | CustFName + CustLName|
| Gender        | NVARCHAR(20)   | NULL                 | Customer's gender                       | Customer             |
| AgeGroup      | NVARCHAR(20)   | NOT NULL             | Age bucket for segmentation             | Derived from DOB     |
| LoyaltyLevel  | NVARCHAR(20)   | NOT NULL             | Loyalty program membership tier         | LoyaltyProgram       |

**Dim_Service**  
_Defines each service and its attributes, including price, type, and satisfaction scores._

| Column Name   | Data Type      | Constraints         | Description                             | Source/Derived     |
|---------------|----------------|----------------------|-----------------------------------------|--------------------|
| ServiceKey    | INT            | PRIMARY KEY, IDENTITY| Surrogate key for each service           | Generated          |
| ServiceID     | INT            | NOT NULL, UNIQUE     | Business key from OLTP system            | Service            |
| ServiceName   | NVARCHAR(100)  | NOT NULL             | Name of the service                      | Service            |
| ServiceTypeKey| INT            | FOREIGN KEY          | Reference to Dim_ServiceType            | Join to ServiceType|
| Duration      | INT            | NOT NULL             | Length of service in minutes            | Service            |
| Price         | DECIMAL(10,2)  | NOT NULL             | Standard price of service               | Service            |
| AvgRating     | DECIMAL(3,2)   | NULL                 | Aggregated feedback score               | Derived            |

**Dim_ServiceType**  
_Categorizes services and supports departmental performance analysis._

| Column Name        | Data Type     | Constraints            | Description                                     | Source/Derived              |
|--------------------|---------------|-------------------------|-------------------------------------------------|-----------------------------|
| ServiceTypeKey     | INT           | PRIMARY KEY, IDENTITY   | Surrogate identifier for service type           | Generated                   |
| ServiceTypeName    | NVARCHAR(50)  | NOT NULL, UNIQUE        | Name of the service category (e.g., Spa)        | Service.ServiceType         |
| ServiceUsageCount  | INT           | NOT NULL, DEFAULT 0     | Number of services booked for this category     | Aggregated from Fact Table  |
| AvgTypeRating      | DECIMAL(3,2)  | NULL                    | Average rating across all services in this type | Aggregated from Dim_Service |
"""


