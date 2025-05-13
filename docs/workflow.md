# 📋 Canyon Ranch DB Project - Workflow Tracker

This document outlines all tasks from Milestone 1 to Milestone 3, broken into small chunks with checkboxes to track progress easily. Updated to reflect use of GPT for data generation.

---

## ✅ Milestone 1: Problem Statement + ER Diagram

### 🔹 Business Problem & Benefits
- [x] Identified operational problems at Canyon Ranch
- [x] Documented risks and expected benefits
- [x] Format and write up the report section

### 🔹 ER Diagram
- [x] Identified all necessary entities and attributes
- [x] Defined relationships, constraints, cardinalities
- [x] Created ER diagram using ERDPlus
- [x] Finalized and exported as `er_diagram.png`
- [x] Submitted milestone 1 report (`milestone1_report.docx`)

---

## ✅ Milestone 2: Logical + Physical Design

### 🔹 Logical Design (Relational Schema)
- [x] Converted ER diagram to relational schema in `schema.sql`
- [x] Created `relational_schema.png` from ERDPlus
- [x] Documented functional dependencies in `functional_dependencies.md`
- [x] Ensured all relations are normalized to 3NF

### 🔹 Physical Design (SQL Server)
- [x] Create schema in SQL Server (`CanyonRanch`)
- [x] Implement all tables in `create_tables.sql`
- [x] Add PKs, FKs, NOT NULLs, CHECKs

### 🔹 Sample Data (AI-Powered)
- [x] Use GPT to generate `INSERT INTO` statements per table
- [x] Maintain referential integrity across inserts
- [x] Validate FKs using test queries (`test_queries.sql`)

### 🔹 Backup
- [x] Create `.bak` file and save to `backup/`

### 🔹 Documentation
- [x] Compile `milestone2_report.docx` with:
  - Schema
  - Functional dependencies
  - Normalization logic
  - Sample data
  - Screenshots

---

## 🚧 Milestone 3: Data Warehouse + Final Deliverables

### 🔹 Dimensional Model
- [x] Identify one fact table (Fact_ReservationService)
- [x] Design three dimension tables (Dim_Date, Dim_Customer, Dim_Service)
- [x] Document dimensional model in `dimensional_modeling.md`

### 🔹 DW Implementation
- [ ] Create CanyonDW database
- [ ] Create dimension tables:
  - [ ] Dim_Date (simplified, removed IsWeekend, IsHoliday, Season)
  - [ ] Dim_Customer
  - [ ] Dim_Service
- [ ] Create fact table:
  - [ ] Fact_ReservationService
- [ ] Add appropriate keys and constraints

### 🔹 ETL Process
- [ ] Develop SQL scripts to populate dimension tables
- [ ] Develop SQL script to populate fact table
- [ ] Test data integrity between OLTP and DW

### 🔹 Analytical Queries
- [ ] Implement sample analytical queries
- [ ] Document query results and insights

### 🔹 Privacy & Ethics
- [ ] Write a section discussing privacy and ethical issues

### 🔹 Final Report
- [ ] Compile final project report with all diagrams and SQL files
- [ ] Submit `.docx`, `.bak`, ER diagrams, and all SQL scripts

---

📌 *Last updated: April 24, 2025 — Simplified Dim_Date table by removing IsWeekend, IsHoliday, and Season attributes.*
