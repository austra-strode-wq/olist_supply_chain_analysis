--Creating view excluding the orders with null delivery dates, as found in previous cleaning queries
CREATE VIEW v_delivered_orders AS 
SELECT *
FROM olist_orders_dataset
WHERE order_status = 'delivered' AND 
		order_delivered_customer_date IS NOT NULL;

--Creating view for easier access to English product translations
CREATE VIEW v_order_items_enriched AS
SELECT 
    ooi.order_id,
    ooi.order_item_id,
    ooi.product_id,
    ooi.seller_id,
    ooi.price,
    ooi.freight_value,
    opd.product_category_name,
    COALESCE(pn.category_name_english, 'Unknown Category') AS category_name_english
FROM olist_order_items_dataset ooi
LEFT JOIN olist_products_dataset opd ON ooi.product_id = opd.product_id
LEFT JOIN product_category_name_translation pn ON opd.product_category_name = pn.category_name_portuguese;

--Checking if COALESCE on categories worked properly: 
SELECT TOP 10 category_name_english,
			price,
			freight_value
FROM v_order_items_enriched
WHERE category_name_english = 'Unknown Category';

--Checking the row count to make sure views have worked
SELECT COUNT(*) AS raw_count FROM olist_order_items_dataset; --112650
SELECT COUNT(*) AS view_count FROM v_order_items_enriched; --112650

--Creating an important analysis view that will be reused multiple times - showing late delivery rate:
CREATE VIEW v_late_delivery_rate AS 
SELECT order_id,
		CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'late'
		ELSE 'on_time' END AS delivery_status
FROM olist_orders_dataset;

--Creating a view for product category performance after analysis queries:
CREATE VIEW v_category_delivery AS 
SELECT category_name_english,
		COUNT(*) AS total_orders,
		SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1 ELSE 0 END) AS late_orders,
		ROUND(SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1
			ELSE 0 END) * 100.0/COUNT(*),2) AS late_percentage_rate,
		CASE WHEN COUNT(*) > 1500 AND 
			ROUND(SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1
			ELSE 0 END) * 100.0/COUNT(*),2) > 10 THEN 'high_orders' 
			WHEN COUNT(*) BETWEEN 500 AND 1000 AND 
			ROUND(SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1
			ELSE 0 END) * 100.0/COUNT(*),2) BETWEEN 5 AND 10 THEN 'mid_orders'
			ELSE 'low_orders' END AS volume_flag
FROM v_order_items_enriched vo
JOIN v_late_delivery_rate ldr ON vo.order_id = ldr.order_id
GROUP BY category_name_english;

--Creating a view for analysis on seller performance: 
CREATE VIEW v_seller_performance AS 
WITH CTE_seller_info AS (
	SELECT sel.seller_id,
		COUNT(*) AS total_orders_fulfilled, 
		SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1 ELSE 0 END) AS late_orders,
		ROUND(SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1
			ELSE 0 END) * 100.0/COUNT(*),2) AS late_percentage_rate
FROM olist_sellers_dataset sel
INNER JOIN olist_order_items_dataset ooi ON sel.seller_id = ooi.seller_id
INNER JOIN v_late_delivery_rate ldr ON ooi.order_id = ldr.order_id
GROUP BY sel.seller_id)
SELECT seller_id,
		total_orders_fulfilled,
		late_percentage_rate,
		RANK() OVER (ORDER BY late_percentage_rate DESC) AS reliability_ranking
FROM CTE_seller_info;

--Creating a view for average delivery lengths from purchase made to delivered to customer per product category:
CREATE VIEW v_category_avg_days AS
SELECT category_name_english,
		AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS days_travelled
FROM v_delivered_orders vdo
JOIN v_order_items_enriched oie ON vdo.order_id = oie.order_id
GROUP BY category_name_english;
