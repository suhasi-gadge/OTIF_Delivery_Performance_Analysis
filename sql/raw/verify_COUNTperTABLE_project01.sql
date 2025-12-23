SELECT 'raw.customers' AS table_name, COUNT(*) FROM raw.customers
UNION ALL
SELECT 'raw.sellers', COUNT(*) FROM raw.sellers
UNION ALL
SELECT 'raw.products', COUNT(*) FROM raw.products
UNION ALL
SELECT 'raw.product_category_name_translation', COUNT(*) FROM raw.product_category_name_translation
UNION ALL
SELECT 'raw.orders', COUNT(*) FROM raw.orders
UNION ALL
SELECT 'raw.order_items', COUNT(*) FROM raw.order_items
UNION ALL
SELECT 'raw.order_payments', COUNT(*) FROM raw.order_payments
UNION ALL
SELECT 'raw.order_reviews', COUNT(*) FROM raw.order_reviews
ORDER BY table_name;
