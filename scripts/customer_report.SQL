/*
================================================================================
Report Name : Customer Consolidated Report View
Author      : Akshatha Kumble Prabhu
Date        : 2025-12-11
Layer       : Gold
Purpose     :
    Provides a unified customer analytics view by integrating demographics,
    behavioural attributes, and aggregated sales performance indicators.

Key Capabilities:
    1. Captures essential customer and transaction attributes to support
       high-value reporting and insight generation.

    2. Applies customer classification logic, including:
         - Customer lifecycle segmentation (VIP, Regular, New)
         - Age group categorisation for demographic analysis

    3. Computes aggregated customer-level metrics:
         - total orders
         - total sales
         - total quantity purchased
         - distinct products purchased
         - lifespan (in months)

    4. Generates analytical KPIs to support customer profiling:
         - recency (months since last order)
         - average order value (AOV)
         - average monthly spend
===============================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO
CREATE VIEW gold.report_customers AS

/*================================================================================
    Step 1: Base Query
    - Extracts core transaction and customer fields from fact and dimension tables.
    - Ensures records contain valid order dates.
================================================================================*/
WITH base_query AS (
    SELECT 
        f.order_number,
        f.order_date,
        f.product_key,
        f.sales_amount,
        f.quantity,

        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age   -- Calculate current age

    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customer c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),

/*================================================================================
    Step 2: Customer-Level Aggregation
    - Aggregates sales metrics for each customer.
    - Computes:
        * Order counts
        * Total sales and quantity
        * Last order date
        * Customer lifespan based on first vs. last order
================================================================================*/
customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan

    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

/*================================================================================
    Step 3: Final Output
    - Adds derived classifications and KPIs:
        * Age grouping
        * Customer segments
        * Recency
        * AOV and Monthly Spend
================================================================================*/
SELECT 
    customer_key,
    customer_number,
    customer_name,

    -- Assign age group classifications
    CASE 
        WHEN age < 30 THEN 'Under 20'
        WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
        WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
        ELSE '50 and above'
    END AS age_group,

    -- Customer segmentation logic based on tenure and sales contribution
    CASE 
        WHEN lifespan > 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan > 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    total_orders,
    total_sales,
    total_quantity,

    -- Months since last order
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    -- Average order value (AOV)
    CASE 
        WHEN total_sales = 0 THEN 0
        ELSE total_sales / total_orders 
    END AS avg_order_value,

    -- Average monthly spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;

