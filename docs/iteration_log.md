# 🧾 Iteration Log — Canyon Ranch DB Project

This log tracks all major updates and file changes made throughout the project across all milestones. It ensures traceability and structured collaboration.

---

### 📅 April 12, 2025

- ✅ Created project folder and directory structure on local machine
- ✅ Finalized and exported ER diagram (`er_diagram.png`)
- ✅ Created initial version of `workflow.md` to track project tasks
- ✅ Added `entity_description.md` with all entity attributes and logic
- ✅ Created `schema_drawings.md` to explain schema transformation and diagram design
- ✅ Decided to use GPT-4 for AI-powered sample data generation instead of using generatedata.com

---

### 📅 April 13, 2025

- ✅ Created GitHub repository and uploaded full folder from local
- ✅ Cloned the GitHub repo into Cursor IDE for structured development
- ✅ Updated `README.md` with file structure, tech stack, and run instructions
- ✅ Integrated workflow tracker into Milestone 1 report as Appendix A
- ✅ Reorganized documentation folder (`/docs`) and finalized Markdown files for entity descriptions, dependencies, and design notes

---

### 📅 April 14, 2025

- ✅ Created comprehensive SQL schema design documentation in `docs/sql_schema_design.md`
- ✅ Implemented complete database schema with all tables, relationships and constraints in `sql/create_schema.sql`
- ✅ Added proper data types for all columns based on entity requirements
- ✅ Implemented foreign key relationships to maintain referential integrity
- ✅ Added appropriate constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT)
- ✅ Created performance-enhancing indexes for commonly joined tables
- ✅ Updated `workflow.md` to mark physical design tasks as completed
- ✅ Created `docs/cloud_db_setup_notes.md` with best practices for database deployment in a cloud environment

---

### 📅 April 15, 2025

- ✅ Created comprehensive sample data with `sql/insert_sample_data.sql`
- ✅ Generated 50+ realistic records across all tables including:
  - 5 facilities with different types and locations
  - 15 customers with diverse preferences and medical histories
  - 18 staff members with various specialties
  - 20 reservations spanning multiple dates
  - 45+ reservation services with appropriate relationships
  - Complete set of payments, feedback, and loyalty program entries
- ✅ Implemented careful ordering of INSERT statements to maintain referential integrity
- ✅ Added data cleanup and identity reset commands for rerunnable script
- ✅ Updated `workflow.md` to mark sample data tasks as completed

---

### 📅 April 24, 2025

- ✅ Created updated database schema version in `sql/create_schema_v4.sql` with significant improvements:
  - Renamed all bridge tables to match relationship names from ER diagram (Provides, QualifiesFor, Includes, AssignedTo, RefersTo)
  - Corrected Affiliate-ReferralSource relationship based on business requirements
  - Added nullable AffiliateID foreign key to ReferralSource table
  - Improved foreign key constraint naming for better readability
  - Enhanced drop table sequence for safer schema updates
  - Updated all indexes to match new table names
  - Added detailed comments for better code documentation
- ✅ Updated workflow.md to reflect schema improvements
- ✅ Began preparation for data warehouse design as part of Milestone 3

---

### 📅 April 25, 2025

- ✅ Created updated database schema version in `sql/create_schema_v5.sql`:
  - Fixed relationship between Affiliate and ReferralSource tables - replaced bridge table with proper one-to-many relationship
  - Added ReferralSourceID as FK directly to Affiliate table
  - Renamed bridge tables to follow consistent naming convention: `[Table1][Table2]Bridge`
  - Removed redundant AssignedDate column from Staff-ReservationService bridge table
- ✅ Updated `sql/data_populate_final.sql` script to match new schema structure
- ✅ Created dimensional modeling documentation in `docs/dimensional_modeling.md`
- ✅ Developed star schema design with one fact table and three dimension tables

---

### 📅 April 28, 2025

- ✅ Created data warehouse implementation script in `sql/dw_implementation.sql`:
  - Implemented DW schema within CanyonRanch database
  - Created Dim_Date, Dim_Customer, and Dim_Service dimension tables
  - Created Fact_ReservationService fact table with appropriate foreign keys
  - Added performance indexes for common analytical queries
- ✅ Created ETL script in `sql/dw_populate.sql` to populate DW tables from source data
- ✅ Designed sample analytical queries to answer key business questions

---

### 📅 April 29, 2025

- ✅ Enhanced dimensional model by transitioning to snowflake schema:
  - Planned new Dim_ServiceType dimension table with extended attributes
  - Created design for normalizing Dim_Service into Service and ServiceType dimensions
  - Documented benefits of hierarchical dimension for service categories
  - Added additional descriptive attributes for service types
- ✅ Updated workflow tracker to reflect DW implementation progress
- ✅ Updated iteration log with all recent changes

---

### 📅 April 30, 2025

- ✅ Implemented snowflake schema in `sql/dw_implementation.sql`:
  - Created Dim_ServiceType table as parent dimension to Dim_Service
  - Added proper foreign key relationships between dimensions
  - Added derived metrics columns (ServiceUsageCount, AvgTypeRating, AvgRating)
  - Created additional indexes for performance optimization
- ✅ Updated `sql/dw_populate.sql` to implement hybrid ETL/ELT approach:
  - ETL for base dimension and fact loading
  - ELT for derived metrics calculation
  - Implemented proper dimension loading sequence (parent before child)
  - Fixed dimension key lookups for fact table population
- ✅ Created documentation on ETL vs ELT approach in `docs/elt+etl.md`
- ✅ Modified business analytical queries to leverage the snowflake schema

---

### 📅 May 1, 2025

- ✅ Created comprehensive data warehouse dictionary in `docs/dw_dictionary.md`:
  - Documented all tables, columns, data types and descriptions
  - Added sample values and source/derived indicators
  - Documented table relationships and ETL processes
  - Included data quality considerations
- ✅ Created ethics and privacy considerations document in `docs/ethics+privacy.md`:
  - Identified key privacy concerns for customer data
  - Documented data warehouse privacy implications
  - Outlined compliance considerations
  - Provided recommendations for security and privacy
- ✅ Updated `workflow.md` to reflect completed Milestone 3 tasks
- ✅ Performed validation testing on data warehouse implementation
- ✅ Fixed joins in fact table population to properly connect to all dimensions

---

