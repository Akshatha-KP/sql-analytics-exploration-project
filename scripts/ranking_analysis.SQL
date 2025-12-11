/*
===============================================================================
SQL Script: Ranking Analysis
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script performs ranking analysis on products based on revenue.
    The analysis includes:
        - Top 5 products generating the highest revenue
        - Alternative approach using window functions for ranking
        - Bottom 5 products generating the least revenue

    Purpose:
        Provides insights into product performance, helping prioritize
        high-revenue products and identify underperforming products.
===============================================================================
*/

-- ================================================
-- Top 5 products generating the highest revenue
-- ================================================
SELECT TOP 5
    p.Product_name,
    SUM(s.Sales_Amount) AS Total_Revenue 
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.Product_key = p.Product_key
GROUP BY p.Product_name
ORDER BY Total_Revenue DESC;

-- ======================================================
-- Top 5 products using window function (alternative)
-- ======================================================
SELECT *
FROM (
    SELECT
        p.Product_name,
        SUM(s.Sales_Amount) AS Total_Revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(s.Sales_Amount) DESC) AS Product_Rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.Product_key = p.Product_key
    GROUP BY p.Product_name
) t
WHERE Product_Rank <= 5;

-- ======================================================
-- Worst 5 performing products (least revenue)
-- ======================================================
SELECT TOP 5
    p.Product_name,
    SUM(s.Sales_Amount) AS Total_Revenue 
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.Product_key = p.Product_key
GROUP BY p.Product_name
ORDER BY Total_Revenue ASC;
