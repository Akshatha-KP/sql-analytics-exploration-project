/*
================================================================================
Report Name : Product Performance Report View
Author      : Akshatha Kumble Prabhu
Date        : 2025-12-11
Layer       : Gold

Purpose:
    Provides a consolidated analytical view of product performance by combining
    product attributes, sales behavior, and aggregated revenue metrics.

Key Capabilities:
    1. Extracts essential product characteristics including product name,
       category, subcategory, and cost.

    2. Classifies products into performance segments based on revenue:
           - High-Performer
           - Mid-Range
           - Low-Performer

    3. Aggregates product-level metrics:
           - total orders
           - total sales
           - total quantity sold
           - unique customer count
           - product lifespan (in months)

    4. Computes analytical KPIs for insight generation:
           - recency (months since last sale)
           - average order revenue (AOR)
           - average monthly revenue
================================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

/*================================================================================
    Step 1: Base Query
    - Retrieves core product and sales-related columns.
    - Ensures only valid transactions with valid order dates are included.
================================================================================*/
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,

        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL  -- Include only valid sales events
),

/*================================================================================
    Step 2: Product Aggregations
    - Summarises sales-related metrics for each product.
    - Computes:
        * total sales
        * total orders
        * total quantity sold
        * product lifespan
        * unique customers
        * average selling price (ASP)
================================================================================*/
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        product_cost,

        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,

        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        -- Average Selling Price (ASP): sales_amount / quantity
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        product_cost
)

/*================================================================================
    Step 3: Final Output
    - Applies segmentation logic and computes KPIs:
        * Revenue-based product segment
        * Recency in months
        * Average Order Revenue (AOR)
        * Average Monthly Revenue
================================================================================*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,
    last_sale_date,

    -- Months since last product sale
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    -- Performance Segmentation based on total sales
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
