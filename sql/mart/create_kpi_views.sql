-- 3.1 vw_order_delivery_kpis (1 row per order)

CREATE OR REPLACE VIEW mart.vw_order_delivery_kpis AS
WITH item_agg AS (
  SELECT
    order_id,
    COUNT(*) AS item_count,
    SUM(COALESCE(price,0)) AS items_value,
    SUM(COALESCE(freight_value,0)) AS freight_total
  FROM mart.fact_order_items
  GROUP BY order_id
)
SELECT
  fo.order_id,
  fo.customer_id,
  dc.customer_city,
  dc.customer_state,

  fo.order_status,
  fo.purchase_ts::date AS purchase_date,
  fo.delivered_customer_ts::date AS delivered_date,
  fo.estimated_delivery_ts::date AS estimated_date,

  fo.delivery_lead_time_days,
  fo.days_late,
  fo.on_time_flag,
  fo.delivered_flag,
  fo.canceled_flag,

  -- OTIF proxy
  CASE WHEN fo.on_time_flag = 1 AND fo.canceled_flag = 0 THEN 1 ELSE 0 END AS otif_proxy_flag,

  ia.item_count,
  ia.items_value,
  ia.freight_total,

  r.review_score

FROM mart.fact_orders fo
LEFT JOIN mart.dim_customer dc ON fo.customer_id = dc.customer_id
LEFT JOIN item_agg ia ON fo.order_id = ia.order_id
LEFT JOIN stg.order_reviews_dedup r ON fo.order_id = r.order_id;


-- 3.2 vw_seller_scorecard

CREATE OR REPLACE VIEW mart.vw_seller_scorecard AS
WITH seller_orders AS (
  SELECT
    foi.seller_id,
    v.order_id,
    v.on_time_flag,
    v.days_late,
    v.otif_proxy_flag,
    v.review_score,
    v.item_count,
    v.freight_total
  FROM mart.fact_order_items foi
  JOIN mart.vw_order_delivery_kpis v
    ON foi.order_id = v.order_id
  GROUP BY foi.seller_id, v.order_id, v.on_time_flag, v.days_late, v.otif_proxy_flag,
           v.review_score, v.item_count, v.freight_total
)
SELECT
  s.seller_id,
  ds.seller_city,
  ds.seller_state,

  COUNT(*) AS orders,
  ROUND(AVG(on_time_flag::numeric) * 100, 2) AS on_time_rate_pct,
  ROUND(AVG(otif_proxy_flag::numeric) * 100, 2) AS otif_proxy_rate_pct,
  ROUND(AVG(days_late::numeric), 2) AS avg_days_late,
  ROUND(AVG(review_score::numeric), 2) AS avg_review_score,
  ROUND(AVG(item_count::numeric), 2) AS avg_items_per_order,
  ROUND(AVG(freight_total::numeric), 2) AS avg_freight_per_order
FROM seller_orders s
LEFT JOIN mart.dim_seller ds ON s.seller_id = ds.seller_id
GROUP BY s.seller_id, ds.seller_city, ds.seller_state;


-- 3.3 vw_category_scorecard

CREATE OR REPLACE VIEW mart.vw_category_scorecard AS
SELECT
  dp.product_category_english AS category,
  COUNT(DISTINCT foi.order_id) AS orders,
  ROUND(AVG(v.on_time_flag::numeric) * 100, 2) AS on_time_rate_pct,
  ROUND(AVG(v.otif_proxy_flag::numeric) * 100, 2) AS otif_proxy_rate_pct,
  ROUND(AVG(v.days_late::numeric), 2) AS avg_days_late,
  ROUND(AVG(v.review_score::numeric), 2) AS avg_review_score
FROM mart.fact_order_items foi
JOIN mart.dim_product dp ON foi.product_id = dp.product_id
JOIN mart.vw_order_delivery_kpis v ON foi.order_id = v.order_id
GROUP BY dp.product_category_english;


-- 3.4 vw_lane_performance (customer_state -> seller_state)

CREATE OR REPLACE VIEW mart.vw_lane_performance AS
WITH order_lane AS (
  SELECT DISTINCT
    foi.order_id,
    ds.seller_state,
    v.customer_state,
    v.on_time_flag,
    v.days_late,
    v.otif_proxy_flag
  FROM mart.fact_order_items foi
  JOIN mart.dim_seller ds ON foi.seller_id = ds.seller_id
  JOIN mart.vw_order_delivery_kpis v ON foi.order_id = v.order_id
)
SELECT
  seller_state,
  customer_state,
  COUNT(*) AS orders,
  ROUND(AVG(on_time_flag::numeric) * 100, 2) AS on_time_rate_pct,
  ROUND(AVG(otif_proxy_flag::numeric) * 100, 2) AS otif_proxy_rate_pct,
  ROUND(AVG(days_late::numeric), 2) AS avg_days_late
FROM order_lane
GROUP BY seller_state, customer_state;


-- 3.5 vw_review_impact (late vs on-time)

CREATE OR REPLACE VIEW mart.vw_review_impact AS
SELECT
  CASE
    WHEN on_time_flag = 1 THEN 'On-time'
    WHEN on_time_flag = 0 THEN 'Late'
    ELSE 'Unknown'
  END AS delivery_bucket,
  COUNT(*) AS orders,
  ROUND(AVG(review_score::numeric), 2) AS avg_review_score,
  ROUND(AVG(days_late::numeric), 2) AS avg_days_late
FROM mart.vw_order_delivery_kpis
GROUP BY 1;

