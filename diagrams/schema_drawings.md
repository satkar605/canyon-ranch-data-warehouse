# 🧱 Schema Design Notes — Canyon Ranch Project

This document explains the reasoning behind the construction of the **ER diagram** and its transformation into a **relational schema**. It supports diagram interpretation and design decisions.

---

## 🔷 ER Diagram Highlights

- **Normalized** to minimize redundancy  
- **Associative Entities**: `Reservation_Service`, `ReferralSource`  
- **Derived Fields** like `Age` not stored directly  
- **Referential integrity** maintained in schema

---

## 🗂️ Entity Mapping Strategy

### Customer
- Includes demographics and preferences
- Age is derived, not stored

### Reservation
- Linked to Customer, Payment, Feedback, Coordinator

### Reservation_Service
- Many-to-many join between Reservation and Service

### Service
- Type, price, duration; tied to Facility and Staff

### Staff
- Role, specialty, availability; tied to services provided

### Program Coordinator
- Assigned to reservations; has schedule/contact

### Facility
- Central unit connecting Rooms, Services, Staff, Coordinators

### Room
- Connected to Facility; includes rate, type, status

### LoyaltyProgram
- Optional program capturing points and tiers

### Payment
- One-to-one with Reservation

### Feedback
- Optional one-to-one with Reservation

### ReferralSource + Affiliate
- Tracks referral origins: customers, affiliates, website

---

## 🛠️ Tools

- ERDPlus for diagramming  
- Exported as `er_diagram.png`, `relational_schema.png`

---

## ✅ Validation

- Entities match `entity_description.md`  
- Normalized as shown in `functional_dependencies.md`

---

*Last updated: April 12, 2025*
