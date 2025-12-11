/*
===============================================================================
SQL Script: Change Over Time Analysis
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script performs change-over-time analysis on sales data to identify 
    trends, growth, and seasonality. Key analyses include:
        - Yearly and monthly sales, customer counts, and quantities
        - Time-series aggregation using different date functions
        - Measuring growth or decline over specific periods

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()

Purpose:
    Helps track sales and customer trends over time, providing insights for 
    forecasting, seasonality detection, and business planning.
===============================================================================
*/

-- ======================================================
-- Sales performance over time using DATEPART
-- ======================================================
SELECT
    YEAR(order_date) AS order_year,          -- Extract year
    MONTH(order_date) AS order_month,        -- Extract month
    SUM(sales_amount) AS total_sales,        -- Total sales in the period
    COUNT(DISTINCT customer_key) AS total_customers,  -- Unique customers
    SUM(quantity) AS total_quantity          -- Total items sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- ======================================================
-- Sales performance over time using DATETRUNC (month)
-- ======================================================
SELECT
    DATETRUNC(month, order_date) AS order_date,  -- Truncate to month
    SUM(sales_amount) AS total_sales,           -- Total sales
    COUNT(DISTINCT customer_key) AS total_customers, -- Unique customers
    SUM(quantity) AS total_quantity             -- Total items sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- ======================================================
-- Sales performance over time using FORMAT (yyyy-MMM)
-- ======================================================
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,  -- Format as year-month
    SUM(sales_amount) AS total_sales,             -- Total sales
    COUNT(DISTINCT customer_key) AS total_customers, -- Unique customers
    SUM(quantity) AS total_quantity               -- Total items sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
