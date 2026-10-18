-- =============================================================================
-- SQL QUIZ 03: ADVANCED MULTI-TABLE JOINS, REVENUE METRICS & SUBQUERIES
-- Regional Demand Analysis, Sales Value Calculations, Scalar Subqueries
-- Author: Islam Yasser (Data Analyst & BI Specialist)
-- Target RDBMS: MySQL 8.0+
-- Database: online_store
-- =============================================================================

USE online_store;

-- =============================================================================
-- SECTION 1: REGIONAL DEMAND & AVERAGE BASKET SIZE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q1: Display the total number of orders and average order quantity
--     placed by customers who reside in Cairo.
-- Technique: Relational INNER JOIN filtered by geographic dimension (city = 'Cairo')
-- Business Metric: Regional order velocity & average units per transaction (UPT).
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(o.order_id) AS cairo_total_orders,
    ROUND(AVG(o.quantity), 2) AS cairo_avg_units_per_order
FROM orders o
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
WHERE c.city = 'Cairo';

-- =============================================================================
-- SECTION 2: CUSTOMER ORDER FREQUENCY RANKING
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q2: Display each customer's full name along with the total number of orders
--     they have placed, sorted from highest order frequency to lowest.
-- Technique: Relational JOIN with GROUP BY and DESCENDING sort.
-- Business Metric: Customer order frequency and repeat purchase distribution.
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(o.order_id) AS total_orders_placed
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_orders_placed DESC, c.full_name ASC;

-- =============================================================================
-- SECTION 3: MULTI-TABLE FINANCIAL REVENUE COMPUTATION
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q3: Display product name, category name, total quantity sold, and total sales
--     revenue generated for each product.
-- Formula: Total Sales Revenue = SUM(product.price * orders.quantity)
-- Technique: 3-Table Join (products -> catgories -> orders) with grouping.
-- Business Metric: Gross merchandise value (GMV) per SKU and category contribution.
-- -----------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    cat.catgory_name AS category_name,
    p.price AS unit_price,
    SUM(o.quantity) AS total_units_sold,
    SUM(p.price * o.quantity) AS total_sales_revenue
FROM products p
INNER JOIN catgories cat 
    ON p.catgory_id = cat.catgory_id
INNER JOIN orders o 
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, cat.catgory_name, p.price
ORDER BY total_sales_revenue DESC;

-- =============================================================================
-- SECTION 4: SCALAR SUBQUERIES (DYNAMIC BENCHMARKING)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q4: Display all products whose price exceeds the catalog-wide average price.
-- Technique: WHERE clause filtering against a dynamic Scalar Subquery (SELECT AVG(price)).
-- Business Metric: Premium / High-margin inventory classification.
-- -----------------------------------------------------------------------------
SELECT 
    product_id,
    product_name,
    price,
    stock,
    (SELECT ROUND(AVG(price), 2) FROM products) AS catalog_avg_price,
    ROUND(price - (SELECT AVG(price) FROM products), 2) AS premium_variance
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- =============================================================================
-- SECTION 5: 4-TABLE RELATIONAL TRAVERSAL & DISTINCT SEGMENTATION
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q5: Display the unique names of all customers who have purchased at least
--     one product belonging to the 'Electronics' category.
-- Technique: 4-Table JOIN (customers -> orders -> products -> catgories) with DISTINCT.
-- Business Metric: High-tech buyer profile extraction for upsell and warranty marketing.
-- -----------------------------------------------------------------------------
SELECT DISTINCT 
    c.customer_id,
    c.full_name,
    c.email,
    c.city
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN products p 
    ON o.product_id = p.product_id
INNER JOIN catgories cat 
    ON p.catgory_id = cat.catgory_id
WHERE cat.catgory_name = 'Electronics'
ORDER BY c.customer_id ASC;
