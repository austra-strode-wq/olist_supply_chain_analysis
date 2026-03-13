--Total orders handled
SELECT COUNT(order_id) AS total_orders
FROM olist_order_items_dataset;
--Ordered items per order 
SELECT COUNT(order_item_id) AS items_per_order
FROM olist_order_items_dataset
GROUP BY order_id
ORDER BY items_per_order DESC;--vast majority is only 1 item per order - might do a case statement later on big-mmed-small orders

--Checking the date range of orders in the database
SELECT MIN(order_purchase_timestamp) AS oldest_order,
		MAX(order_purchase_timestamp) AS newest_order,
		DATEDIFF(YEAR, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS diff
FROM olist_orders_dataset;

--Checking for possible order trends by month
SELECT COUNT(order_id) AS orders_placed,
		DATENAME(year, order_purchase_timestamp) AS year,
		DATENAME(month, order_purchase_timestamp) AS month
FROM olist_orders_dataset
GROUP BY DATENAME(year, order_purchase_timestamp),
		DATENAME(month, order_purchase_timestamp)
ORDER BY year, orders_placed DESC;

--Checking counts on unique sellers, customers and product categories
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM olist_customers_dataset;

SELECT COUNT(DISTINCT seller_id) AS unique_sellers
FROM olist_sellers_dataset;

SELECT COUNT(DISTINCT product_id) AS unique_products,
		COUNT(DISTINCT product_category_name) AS unique_categories
FROM olist_products_dataset;
