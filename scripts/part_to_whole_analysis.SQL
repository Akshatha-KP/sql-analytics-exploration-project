/*
===============================================================================
SQL Script: Part-to-Whole Analysis
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script performs part-to-whole analysis by calculating the proportion 
    of each product category's sales relative to total sales. Key calculations include:
        - Total sales per category
        - Overall sales across all categories
        - Percentage contribution of each category to overall sales

    Purpose:
        Helps identify which categories contribute the most to total revenue,
        supporting prioritization and strategic decision-making.
===============================================================================
*/

-- ======================================================
-- Step 1: Calculate total sales per category
-- ======================================================
WITH Category_sales AS (
    SELECT 
        p.Category,
        SUM(f.Sales_amount) AS Total_Sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.Product_key = p.Product_key
    GROUP BY p.Category
)

-- ======================================================
-- Step 2: Calculate part-to-whole proportions
-- ======================================================
SELECT 
    Category,
    Total_Sales,
    
    -- Total sales across all categories
    SUM(Total_Sales) OVER() AS Overall_Sales,
    
    -- Percentage contribution of each category to overall sales
    CONCAT(
        ROUND(
            (CAST(Total_Sales AS FLOAT) / SUM(Total_Sales) OVER()) * 100,
            2
        ), 
        '%'
    ) AS Percentage_Of_Total

FROM Category_sales
ORDER BY Percentage_Of_Total DESC;
