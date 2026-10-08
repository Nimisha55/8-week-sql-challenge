/*
====================================================
8 Week SQL Challenge
Case Study #1: Danny's Diner
Initial Data Exploration
====================================================
*/

-- 1. Preview the datasets
SELECT * FROM dannys_diner.sales;

SELECT * FROM dannys_diner.menu;

SELECT * FROM dannys_diner.members;


-- 2. Count total sales records
SELECT COUNT(*) AS total_sales
FROM dannys_diner.sales;


-- 3. Count unique customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM dannys_diner.sales;


-- 4. Check the date range of transactions
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM dannys_diner.sales;


-- 5. Count available menu items
SELECT COUNT(*) AS total_menu_items
FROM dannys_diner.menu;


-- 6. Count loyalty program members
SELECT COUNT(*) AS total_members
FROM dannys_diner.members;


-- 7. Check for missing values in sales
SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL)
        AS missing_customer_ids,
    COUNT(*) FILTER (WHERE order_date IS NULL)
        AS missing_order_dates,
    COUNT(*) FILTER (WHERE product_id IS NULL)
        AS missing_product_ids
FROM dannys_diner.sales;


-- 8. Check whether sales reference valid menu items
SELECT DISTINCT s.product_id
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
    ON s.product_id = m.product_id
WHERE m.product_id IS NULL;