-- Mart level Data Quality Checks

-- 1) duplicates in facts
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM mart.fact_orders;

SELECT COUNT(*) AS null_order_ids
FROM mart.fact_orders
WHERE order_id IS NULL;

-- 2) null timestamp rates
SELECT
  ROUND(100.0 * SUM(CASE WHEN delivered_customer_ts IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS delivered_null_pct,
  ROUND(100.0 * SUM(CASE WHEN estimated_delivery_ts IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS estimated_null_pct
FROM mart.fact_orders;

-- 3) sanity checks: days_late distribution
SELECT
  MIN(days_late) AS min_days_late,
  MAX(days_late) AS max_days_late,
  ROUND(AVG(days_late::numeric), 2) AS avg_days_late
FROM mart.fact_orders
WHERE days_late IS NOT NULL;

-- 4) on-time rate sanity
SELECT
  ROUND(AVG(on_time_flag::numeric) * 100, 2) AS on_time_rate_pct
FROM mart.fact_orders
WHERE on_time_flag IS NOT NULL;

-- 5) on-time rate by status
SELECT
  order_status,
  COUNT(*) AS orders,
  ROUND(AVG(on_time_flag::numeric) * 100, 2) AS on_time_rate_pct
FROM mart.fact_orders
WHERE on_time_flag IS NOT NULL
GROUP BY order_status
ORDER BY orders DESC;


-- 6) confirm outliers count (how many are extreme)
SELECT
  SUM(CASE WHEN days_late >= 30 THEN 1 ELSE 0 END) AS late_30_plus,
  SUM(CASE WHEN days_late >= 60 THEN 1 ELSE 0 END) AS late_60_plus,
  SUM(CASE WHEN days_late <= -30 THEN 1 ELSE 0 END) AS early_30_plus,
  SUM(CASE WHEN days_late <= -60 THEN 1 ELSE 0 END) AS early_60_plus
FROM mart.fact_orders
WHERE days_late IS NOT NULL;

