/*
===============================================================================
SQL Script: Date Range Exploration
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script explores the temporal aspects of key data in the Gold layer. 
    The analysis includes:
        - Determining the first and last order dates and the duration of sales data
        - Identifying the youngest and oldest customers based on birthdate

SQL Functions Used:
    - MIN(), MAX(): To find earliest and latest dates
    - DATEDIFF(): To calculate differences in months or years
    - GETDATE(): To compute ages relative to the current date

Purpose:
    Helps understand historical data coverage and the age distribution of customers,
    which is essential for time-based analysis and reporting.
===============================================================================
*/

-- ======================================================
-- Determine the first and last order date and the total duration in months
-- ======================================================
SELECT 
    MIN(order_date) AS first_order_date,  -- Earliest order
    MAX(order_date) AS last_order_date,   -- Latest order
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months  -- Total duration in months
FROM gold.fact_sales;

-- ======================================================
-- Find the youngest and oldest customer based on birthdate
-- ======================================================
SELECT
    MIN(birthdate) AS oldest_birthdate,                    -- Earliest birthdate
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,  -- Age of oldest customer
    MAX(birthdate) AS youngest_birthdate,                  -- Latest birthdate
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age -- Age of youngest customer
FROM gold.dim_customers;
