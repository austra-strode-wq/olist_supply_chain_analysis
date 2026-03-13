--Calculate on-time vs late delivery rate overall, using a created view
SELECT ROUND(SUM(CASE WHEN delivery_status = 'late' THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS late_percentage
FROM v_late_delivery_rate;

--Calculate average order count per category for better flagging on category importance - 1564: 
SELECT AVG(total_orders) AS avg_orders_per_category
FROM (
    SELECT category_name_english,
           COUNT(*) AS total_orders
    FROM v_order_items_enriched
    GROUP BY category_name_english
) AS category_counts;

--Check late delivery rate by product category, also flagging the biggest ordered categories from earlier query
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
GROUP BY category_name_english
ORDER BY late_percentage_rate DESC;

--Check late delivery rate by seller
SELECT sel.seller_id,
		sel.seller_city,
		COUNT(*) AS total_orders_fulfilled, 
		SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1 ELSE 0 END) AS late_orders,
		ROUND(SUM(CASE WHEN ldr.delivery_status = 'late' THEN 1
			ELSE 0 END) * 100.0/COUNT(*),2) AS late_percentage_rate
FROM olist_sellers_dataset sel
INNER JOIN olist_order_items_dataset ooi ON sel.seller_id = ooi.seller_id
INNER JOIN v_late_delivery_rate ldr ON ooi.order_id = ldr.order_id
GROUP BY sel.seller_id, 
		sel.seller_city
HAVING COUNT(*) > 50
ORDER BY total_orders_fulfilled DESC, late_percentage_rate;

--Calculating the average days it takes for delivery to be made per category;
SELECT category_name_english,
		AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS days_travelled
FROM v_delivered_orders vdo
JOIN v_order_items_enriched oie ON vdo.order_id = oie.order_id
GROUP BY category_name_english;

--Ranking the sellers by their late delivery rates, using CTE for readability
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




