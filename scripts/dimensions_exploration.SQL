/*
===============================================================================
SQL Script: Dimensions Exploration
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server / Gold Layer
Description  : 
    This script explores the dimension tables in the Gold layer. The analysis includes:
        - Retrieving unique values from dimension tables to understand data distribution
        - Inspecting customer countries and product categories

SQL Functions Used:
    - DISTINCT: To get unique values
    - ORDER BY: To sort the results for readability

Purpose:
    Helps understand the structure and contents of dimension tables for analysis,
    reporting, and ensuring data quality.
===============================================================================
*/

-- ======================================================
-- Retrieve a list of unique countries from which customers originate
-- ======================================================
SELECT DISTINCT 
    country  -- Customer country
FROM gold.dim_customers
ORDER BY country;

-- ======================================================
-- Retrieve a list of unique categories, subcategories, and products
-- ======================================================
SELECT DISTINCT 
    category,       -- Product category
    subcategory,    -- Product subcategory
    product_name    -- Product name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
