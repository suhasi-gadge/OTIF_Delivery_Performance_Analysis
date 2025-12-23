/* ============================================================
   Day 1 — Join Validation (stg)
   Goal: prove relationships work + quantify coverage
   ============================================================ */

-- 0) Quick row counts (reference)
SELECT 'stg.orders' AS table_name, COUNT(*) AS row_count FROM stg.orders
UNION ALL SELECT 'stg.customers', COUNT(*) FROM stg.customers
UNION ALL SELECT 'stg.order_items', COUNT(*) FROM stg.order_items
UNION ALL SELECT 'stg.sellers', COUNT(*) FROM stg.sellers
UNION ALL SELECT 'stg.products', COUNT(*) FROM stg.products
UNION ALL SELECT 'stg.order_reviews_dedup', COUNT(*) FROM stg.order_reviews_dedup
ORDER BY table_name;


-- 1) orders ↔ customers (coverage %)
SELECT
  COUNT(*) AS orders_total,
  COUNT(c.customer_id) AS orders_with_customer,
  ROUND(100.0 * COUNT(c.customer_id) / COUNT(*), 2) AS customer_join_coverage_pct
FROM stg.orders o
LEFT JOIN stg.customers c
  ON o.customer_id = c.customer_id;


-- 2) orders ↔ order_items (coverage %)
SELECT
  COUNT(*) AS orders_total,
  COUNT(oi.order_id) AS orders_with_items,
  ROUND(100.0 * COUNT(oi.order_id) / COUNT(*), 2) AS items_join_coverage_pct
FROM stg.orders o
LEFT JOIN (
  SELECT DISTINCT order_id
  FROM stg.order_items
) oi
  ON o.order_id = oi.order_id;


-- 3) order_items ↔ sellers (missing seller_id rows)
SELECT
  COUNT(*) AS line_items_total,
  SUM(CASE WHEN s.seller_id IS NULL THEN 1 ELSE 0 END) AS line_items_missing_seller,
  ROUND(100.0 * SUM(CASE WHEN s.seller_id IS NULL THEN 1 ELSE 0 END) / COUNT(*), 4) AS missing_seller_pct
FROM stg.order_items oi
LEFT JOIN stg.sellers s
  ON oi.seller_id = s.seller_id;


-- 4) order_items ↔ products (missing product_id rows)
SELECT
  COUNT(*) AS line_items_total,
  SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END) AS line_items_missing_product,
  ROUND(100.0 * SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END) / COUNT(*), 4) AS missing_product_pct
FROM stg.order_items oi
LEFT JOIN stg.products p
  ON oi.product_id = p.product_id;


-- 5) orders ↔ reviews_dedup (coverage %)
SELECT
  COUNT(*) AS orders_total,
  COUNT(r.order_id) AS orders_with_review,
  ROUND(100.0 * COUNT(r.order_id) / COUNT(*), 2) AS review_coverage_pct
FROM stg.orders o
LEFT JOIN stg.order_reviews_dedup r
  ON o.order_id = r.order_id;


-- 6) Extra: check duplicates where they shouldn't exist
-- orders should be 1 row per order_id
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_id) AS distinct_order_ids,
  (COUNT(*) - COUNT(DISTINCT order_id)) AS duplicate_order_rows
FROM stg.orders;

-- customers should be 1 row per customer_id
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT customer_id) AS distinct_customer_ids,
  (COUNT(*) - COUNT(DISTINCT customer_id)) AS duplicate_customer_rows
FROM stg.customers;

-- dedup reviews should be 1 row per order_id
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_id) AS distinct_order_ids,
  (COUNT(*) - COUNT(DISTINCT order_id)) AS duplicate_review_rows
FROM stg.order_reviews_dedup;
