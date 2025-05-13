# Canyon Ranch Database Project

This project designs and deploys a centralized relational database system for Canyon Ranch, a wellness resort, to improve reservation handling, staff coordination, and customer experience. It follows a structured development process across three milestones and includes both relational and data warehouse models.

## Project Description

Canyon Ranch is a U.S.-based luxury wellness resort brand operating since 1979, offering personalized spa, fitness, and health services. Despite its premium positioning, the organization faced operational inefficiencies due to fragmented legacy systems managing reservations, services, and guest feedback across multiple platforms.

To address these challenges, a centralized relational database and dimensional data warehouse were designed and implemented. The system enables integrated reservation tracking, referral attribution, feedback analysis, and department-level reporting. It supports daily operations and empowers business users with self-service insights for better decision-making.

## Project Objectives and Solution Design

The goal of this project was to deliver an integrated data system that replaces Canyon Ranch's fragmented reservation and service tracking processes. The solution was designed to support both operational workflows and analytical reporting across departments such as guest services, marketing, and program coordination.

### Primary Objectives

- Centralize reservation, guest, and service data to eliminate manual reconciliation across systems
- Enable tracking and analysis of referral sources, including affiliates, website traffic, and guest referrals
- Capture guest feedback linked to services and use this data to evaluate service quality and staff performance
- Support time-based and service-based trend reporting through a scalable data warehouse model

### Solution Design

- **Relational Database (OLTP)**: A fully normalized schema in SQL Server was built to support day-to-day transactions, covering guests, reservations, services, staff, rooms, and feedback.
- **Dimensional Data Warehouse (OLAP)**: A snowflake schema was designed with one fact table (service bookings) and four supporting dimensions (Date, Customer, Service, Service Type) to enable trend analysis, segmentation, and department-level reporting.
- **ETL & ELT Pipelines**: Structured ETL processes handled initial data loading. ELT logic computed key business metrics such as average service ratings and usage counts by service category, directly in the warehouse.

## Data Architecture Overview

The Canyon Ranch data system is structured around two core components: a relational database for operational integrity and a snowflake-modeled data warehouse for analytical flexibility. This dual-layered design ensures data consistency at the transaction level and enables cross-sectional analysis for decision-making.

### 1. Operational Database (Relational Schema)

The relational database was designed in Third Normal Form (3NF) to eliminate redundancy, enforce referential integrity, and streamline service coordination across departments. Key entities include:

- **Guest and Reservation**: Tracks customer profiles, room bookings, and visit details.
- **Services and Staff**: Links service offerings with availability, pricing, and assigned staff.
- **Referrals and Affiliates**: Captures referral source types—affiliate, website, and word-of-mouth—and ties them to actual bookings.
- **Feedback and Loyalty**: Integrates satisfaction ratings and reward tracking for personalized guest management.

  ![er_diagram](https://github.com/user-attachments/assets/42e07810-82f0-41d8-b272-52e334653bce)
  
![relational_schema](https://github.com/user-attachments/assets/53530b6d-8d37-4011-9d51-29a0717094b6)

  


### 2. Analytical Layer (Snowflake Data Warehouse)

The data warehouse supports performance monitoring and department-level reporting. It was built using a snowflake schema, with normalized dimension tables to support hierarchical queries and reduce duplication.

- **Fact Table**: Fact_ReservationService (grain = one row per booked service)
- **Dimensions**:
  - Dim_Date: enables seasonal and trend analysis
  - Dim_Customer: supports demographic and loyalty segmentation
  - Dim_Service: links bookings to specific services
  - Dim_ServiceType: supports rollups by department (Spa, Fitness, Nutrition, etc.)

Derived metrics computed through ELT include:
- Average service rating (by service and by category)
- Booking volume per service type
- Department-level satisfaction scores

![data_warehouse_schema](https://github.com/user-attachments/assets/a6e884e4-cf66-4e1e-9513-d96192d34e84)


## Key Business Insights

The Canyon Ranch data warehouse enabled structured analysis across service categories, customer segments, referral sources, and satisfaction ratings. Data was populated using synthetically generated records aligned with business logic, allowing for realistic simulations of booking behavior, revenue patterns, and guest feedback.

### 1. Referral Source Performance

Affiliate referrals, while lower in volume than website and word-of-mouth sources, generated the highest average spend per guest and stronger return visit patterns. Website referrals had the largest volume but contributed lower revenue per booking. This insight suggests that affiliate channels are undervalued relative to their quality and should be prioritized for growth through targeted incentives or upgraded tracking.

### 2. Reservation and Service Trends

Bookings peaked during weekends and in Q2, with spa services consistently dominating demand. Fitness and coaching services were secondary in volume but showed greater growth over time. This highlights opportunities to adjust staffing levels seasonally and cross-promote underutilized services during off-peak periods through packaged offerings.

### 3. Service Quality and Guest Satisfaction

Spa services received the highest average ratings, while nutrition and coaching services had the most varied feedback. This variation was often linked to individual staff members. By linking service feedback to specific bookings and providers, Canyon Ranch can now identify training needs and support quality assurance at the staff level.

### 4. Analytical Reporting and Department Visibility

The warehouse enables department heads to monitor performance metrics like booking volume, average revenue, and service satisfaction—broken down by service category, referral type, and guest demographic. The snowflake model supports real-time slicing of trends without modifying the schema, enabling self-service dashboards that inform scheduling, marketing, and quality decisions.

## Tech Stack

- **MS SQL Server** (database engine)
- **Microsoft Copilot** (code editing)
- **ERDPlus** (diagramming tool)
- **Markdown + Word** (documentation)
- **GPT-4** (sample data generation)

## Project Structure

```
canyon-ranch-db/
├── sql/                      # SQL scripts
│   ├── create_schema.sql     # Database schema creation script
│   ├── insert_sample_data.sql # Sample data population script
│   └── test_queries.sql      # Validation queries
│
├── docs/                     # Documentation
│   ├── entity_description.md # Entity details and attributes
│   ├── functional_dependencies.md # Functional dependencies documentation
│   ├── sql_schema_design.md  # SQL schema design decisions
│   ├── cloud_db_setup_notes.md # Cloud deployment guidelines
│   ├── Milestone1Report.docx # First milestone report
│   └── TeamProjectInstructions.docx # Project instructions
│
├── diagrams/                 # Visual representations
│   ├── er_diagram.png        # Entity-Relationship diagram
│   └── relational_schema.png # Relational schema diagram
│
├── backup/                   # Database backups
│   └── canyon_ranch_YYYYMMDD.bak # SQL Server backup file
│
├── workflow.md               # Project tracker with task status
├── iteration_log.md          # Log of all project updates
└── README.md                 # Project overview and instructions
```

## How to Run

1. Open the project.
2. Run `create_tables.sql` in your SQL Server instance to create all tables.
3. Load mock data using `insert_sample_data.sql`.
4. Use `test_queries.sql` to validate table joins and foreign key integrity.
5. Generate backup file `.bak` using SQL Server Management Studio.

## Project Status

See `workflow.md` for detailed task tracking and milestone progress.

## Authors

- Satkar Karki  
- Riti Dahal  
- Sabun Dhital  

University of South Dakota – DSCI 723 Spring 2025  
Instructor: Dr. Hanus
