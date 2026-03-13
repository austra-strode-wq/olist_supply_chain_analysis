--Checking for NULLs in most important tables regarding deliveries:
SELECT COUNT(*) - COUNT(customer_id) AS null_customers,
		COUNT(*) - COUNT(customer_unique_id) AS null_uniques,
		COUNT(*) - COUNT(customer_city) AS null_city,
		COUNT(*) - COUNT(customer_state) AS null_state
FROM olist_customers_dataset;

SELECT COUNT(*) - COUNT(order_id) AS null_orders,
		COUNT(*) - COUNT(customer_id) AS null_customers,
		COUNT(*) - COUNT(order_status) AS null_status,
		COUNT(*) - COUNT(order_purchase_timestamp) AS null_timestamp,
		COUNT(*) - COUNT(order_approved_at) AS null_approvals,
		COUNT(*) - COUNT(order_delivered_carrier_date) AS null_carrier_date,
		COUNT(*) - COUNT(order_delivered_customer_date) AS null_customer_date,
		COUNT(*) - COUNT(order_estimated_delivery_date) AS null_estimated_date
FROM olist_orders_dataset;

--Double checking a bit more in depth what's going on with the orders with no delivery date - important for my Business question on reliability
SELECT COUNT(order_status) AS COUNTS,
		order_status
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status;

SELECT COUNT(*) - COUNT(order_id) AS null_id,
		COUNT(*) - COUNT(order_item_id) AS null_order_item,
		COUNT(*) - COUNT(product_id) AS null_product,
		COUNT(*) - COUNT(seller_id) AS null_seller,
		COUNT(*) - COUNT(shipping_limit_date) AS null_ship_limit
FROM olist_order_items_dataset;

SELECT COUNT(*) - COUNT(product_id) AS null_products,
		COUNT(*) - COUNT(product_category_name) AS null_name
FROM olist_products_dataset;

SELECT COUNT(*) - COUNT(seller_id) AS null_seller,
		COUNT(*) - COUNT(seller_state) AS null_state
FROM olist_sellers_dataset;

SELECT COUNT(*) - COUNT(column1) AS null_brasilian,
		COUNT(*) - COUNT(column2) AS null_english
FROM product_category_name_translation;