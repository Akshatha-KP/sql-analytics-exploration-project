/*
===============================================================================
SQL Script: Performance Analysis
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script analyzes the performance of products over time by comparing 
    current sales with both the average sales of the product and the previous 
    year's sales. Key metrics calculated include:
        - Total current sales per product per year
        - Average sales per product
        - Difference from average sales
        - Year-over-year (YoY) sales change
        - Classification of performance as Above Average, Below Average, or Average
        - Classification of YoY performance as Increase, Decrease, or No Change

    Purpose:
        Helps assess product performance trends, identify top and underperforming
        products, and track changes in sales over time.
===============================================================================
*/

-- ======================================================
-- Step 1: Calculate yearly sales for each product
-- ======================================================
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.Order_date) AS Order_Year,
        p.Product_Name,
        SUM(f.Sales_amount) AS Total_Current_Sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.Product_key = p.Product_key
    WHERE f.Order_date IS NOT NULL
    GROUP BY YEAR(f.Order_date), p.Product_Name
)

-- ======================================================
-- Step 2: Compare current sales with average and previous year
-- ======================================================
SELECT 
    Order_Year,
    Product_Name,
    Total_Current_Sales,
    
    -- Average sales for the product across all years
    AVG(Total_Current_Sales) OVER (PARTITION BY Product_Name) AS Avg_Current_Sales,
    
    -- Difference from average sales
    Total_Current_Sales - AVG(Total_Current_Sales) OVER (PARTITION BY Product_Name) AS Diff_Avg_Sales,
    
    -- Categorize performance relative to average
    CASE 
        WHEN Total_Current_Sales - AVG(Total_Current_Sales) OVER (PARTITION BY Product_Name) > 0 THEN 'Above Average'
        WHEN Total_Current_Sales - AVG(Total_Current_Sales) OVER (PARTITION BY Product_Name) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS Avg_change,
    
    -- Previous year's sales for comparison
    LAG(Total_Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) AS Py_sales,
    
    -- Difference from previous year's sales
    Total_Current_Sales - LAG(Total_Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) AS Diff_py_sales,
    
    -- Categorize year-over-year performance
    CASE 
        WHEN Total_Current_Sales > LAG(Total_Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) THEN 'Increase'
        WHEN Total_Current_Sales < LAG(Total_Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY Product_Name, Order_Year;
