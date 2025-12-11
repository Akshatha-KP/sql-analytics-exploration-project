/*
===============================================================================
SQL Script: Data Segmentation Analysis
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script performs data segmentation to categorize products and customers 
    into meaningful groups. The analysis includes:
        - Segmenting products by cost ranges
        - Segmenting customers based on spending behavior and lifespan
        - Counting the number of items/customers in each segment

SQL Functions Used:
    - CASE: Defines custom segmentation rules
    - GROUP BY: Aggregates data by segments
    - DATEDIFF(): Calculates lifespan of customers in months
    - Aggregate Functions: SUM(), COUNT(), MIN(), MAX()

Purpose:
    Supports targeted insights for business strategy, marketing, and sales 
    by identifying key product ranges and customer segments.
===============================================================================
*/

-- ======================================================
-- Segment products into cost ranges and count total products per segment
-- ======================================================
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,                -- Product cost segment
    COUNT(product_key) AS total_products  -- Number of products in the segment
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- ======================================================
-- Segment customers based on spending and lifespan
-- ======================================================
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,              -- Total spending by customer
        MIN(order_date) AS first_order,                     -- First order date
        MAX(order_date) AS last_order,                      -- Last order date
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan  -- Customer lifespan in months
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,                   -- Customer segment
    COUNT(customer_key) AS total_customers  -- Number of customers in segment
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
