/*
===============================================================================
SQL Script: Database Exploration
===============================================================================
Author       : Akshatha Kumble Prabhu
Date         : 2025-12-11
Environment  : SQL Server
Description  : 
    This script is used to explore the structure and metadata of the database. 
    The analysis includes:
        - Retrieving a list of all tables in the database along with schema and type
        - Inspecting columns, data types, and constraints for a specific table (dim_customers)

Purpose:
    Helps understand the database design, table structures, and column metadata 
    before performing further data analysis or transformations.
===============================================================================
*/

-- ======================================================
-- Retrieve a list of all tables in the database
-- ======================================================
SELECT 
    TABLE_CATALOG,  -- Database name
    TABLE_SCHEMA,   -- Schema name
    TABLE_NAME,     -- Table name
    TABLE_TYPE      -- Type of table (BASE TABLE, VIEW)
FROM INFORMATION_SCHEMA.TABLES;

-- ======================================================
-- Retrieve all columns and metadata for the dim_customers table
-- ======================================================
SELECT 
    COLUMN_NAME,                  -- Column name
    DATA_TYPE,                    -- Data type
    IS_NULLABLE,                  -- Indicates if NULLs are allowed
    CHARACTER_MAXIMUM_LENGTH      -- Max character length for string columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
