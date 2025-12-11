/*
===============================================================================
SQL Script: Cumulative Analysis
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script performs cumulative analysis on sales data to calculate running 
    totals and moving averages over time. The analysis includes:
        - Total sales per time period (yearly)
        - Running total of sales
        - Moving average of selling price

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Aggregate Functions: SUM(), AVG()
    - Date Functions: DATETRUNC()

Purpose:
    Useful for growth analysis, tracking long-term trends, and measuring cumulative
    performance of sales metrics over time.
===============================================================================
*/

-- ======================================================
-- Calculate total sales per year and cumulative metrics
-- ======================================================
SELECT
    order_date,                                    -- Truncated to year
    total_sales,                                   -- Total sales for the year
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,  -- Cumulative sales
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price    -- Moving average of price
FROM
(
    -- Subquery: Aggregate sales and average price per year
    SELECT 
        DATETRUNC(year, order_date) AS order_date,  -- Year of order
        SUM(sales_amount) AS total_sales,          -- Total sales
        AVG(price) AS avg_price                     -- Average selling price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t;
