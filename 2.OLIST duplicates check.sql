--Checking for duplicates in primary key columns: 
SELECT COUNT(*), customer_id
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*)>1;

SELECT COUNT(*) AS total_rows,
		COUNT(DISTINCT customer_id) AS uniques
FROM olist_customers_dataset;

SELECT COUNT(*), order_id, order_item_id
FROM olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) >1;

SELECT COUNT(*), seller_id
FROM olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) >1

SELECT COUNT(*), product_id
FROM olist_products_dataset
GROUP BY product_id
HAVING COUNT(*)>1;