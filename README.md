# 🚔 Stolen Vehicles Analysis – SQL Project

## 📌 Project Overview
This SQL project analyzes vehicle theft data from the `stolen_vehicles_db` database to uncover trends about when, where, and what types of vehicles are most likely to be stolen. It applies advanced SQL techniques to support data-driven crime prevention strategies and law enforcement decision-making.

---

## 📁 Database Schema
- `stolen_vehicles`: Main fact table with theft event data (date, vehicle info, location ID)
- `make_details`: Dimension table classifying vehicle makes (Standard vs Luxury)
- `locations`: Region-level info with population and density data

---

## 🎯 Objectives & Tasks

### 🕒 Objective 1: When Are Vehicles Most Likely Stolen?
- Count thefts by **year**, **month**, and **day** using `YEAR()`, `MONTH()`, `DAY()`
- Analyze **daily patterns** with `DAYOFWEEK()` and convert to readable weekday names via `CASE`
- Examine **hourly distribution** of thefts

### 🚗 Objective 2: What Types of Vehicles Are Stolen?
- Identify **top 5 most** and **least stolen** vehicle types
- Compute **average age** of stolen vehicles by type using model year vs theft year
- Calculate **percentage of Luxury vs Standard** vehicles stolen by type via `CASE`, `JOIN`, and CTE
- Create a **color breakdown table** for top 10 vehicle types across 7 common colors (plus “Other”)

### 🗺 Objective 3: Where Are Vehicles Most Likely Stolen?
- Count thefts by **region** using a `LEFT JOIN` with `locations`
- Combine theft counts with **region population and density**
- Use **window functions** (`ROW_NUMBER()`) to:
  - Compare vehicle types stolen in the **3 most** vs **3 least** densely populated regions
  - Rank top 3 vehicle types in each region category

---

## 🛠 SQL Concepts & Techniques Used
- Aggregation: `COUNT()`, `AVG()`, `GROUP BY`
- Date functions: `YEAR()`, `MONTH()`, `DAY()`, `DAYOFWEEK()`
- Conditional logic: `CASE WHEN`
- Filtering and subsetting with `WHERE`, `LIMIT`
- Joins: `LEFT JOIN`, multi-table joins
- Common Table Expressions (CTEs) for reusability and layered logic
- Window functions: `ROW_NUMBER() OVER(PARTITION BY ...)` for ranking

---

## 📂 File Included
- `Stolen_Vehicles_Analysis.sql`: Full script organized by 3 main objectives with labeled tasks and readable comments

---

## 📚 What This Project Demonstrates
- Real-world problem-solving with SQL in a law enforcement/public
