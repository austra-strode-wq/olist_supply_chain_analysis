--Changing style from lower to upper
UPDATE olist_customers_dataset
SET customer_city = UPPER(customer_city);

--Changing datatypes for better readability on currency
ALTER TABLE olist_order_items_dataset
ALTER COLUMN price money;

ALTER TABLE olist_order_items_dataset
ALTER COLUMN freight_value money;

ALTER TABLE olist_order_payments_dataset
ALTER COLUMN payment_value money;

--Check if Zip code prefixes are the same in several columns
SELECT DISTINCT c.customer_zip_code_prefix
FROM olist_customers_dataset c
LEFT JOIN olist_geolocation_dataset g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT DISTINCT s.seller_zip_code_prefix
FROM olist_sellers_dataset s
LEFT JOIN olist_geolocation_dataset g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

--Checking for possible datatype discrepancies in date columns
SELECT DATA_TYPE, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'olist_orders_dataset'
AND COLUMN_NAME LIKE '%date%' 
OR COLUMN_NAME LIKE '%timestamp%';

--Cleaning up the English translations table, giving proper column names
DELETE FROM product_category_name_translation
WHERE column1 = 'product_category_name' AND 
		column2 = 'product_category_name_english';
EXEC sp_rename 'product_category_name_translation.column1', 'category_name_portuguese', 'COLUMN';
EXEC sp_rename 'product_category_name_translation.column2', 'category_name_english', 'COLUMN';
