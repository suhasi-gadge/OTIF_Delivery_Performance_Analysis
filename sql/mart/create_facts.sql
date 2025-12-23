-- 2.1 fact_orders (1 row per order)

DROP TABLE IF EXISTS mart.fact_orders;

CREATE TABLE mart.fact_orders AS
SELECT
  o.order_id,
  o.customer_id,
  o.order_status,

  o.purchase_ts,
  o.approved_ts,
  o.delivered_carrier_ts,
  o.delivered_customer_ts,
  o.estimated_delivery_ts,

  -- Flags
  CASE WHEN o.delivered_customer_ts IS NOT NULL THEN 1 ELSE 0 END AS delivered_flag,
  CASE WHEN o.order_status IN ('canceled', 'unavailable') THEN 1 ELSE 0 END AS canceled_flag,

  -- Lead time (days)
  CASE
    WHEN o.purchase_ts IS NOT NULL AND o.delivered_customer_ts IS NOT NULL
    THEN (o.delivered_customer_ts::date - o.purchase_ts::date)
  END AS delivery_lead_time_days,

  -- Days late (positive = late, negative = early)
  CASE
    WHEN o.delivered_customer_ts IS NOT NULL AND o.estimated_delivery_ts IS NOT NULL
    THEN (o.delivered_customer_ts::date - o.estimated_delivery_ts::date)
  END AS days_late,

  -- On-time flag (1 = delivered on/before estimate)
  CASE
    WHEN o.delivered_customer_ts IS NOT NULL AND o.estimated_delivery_ts IS NOT NULL
         AND o.delivered_customer_ts::date <= o.estimated_delivery_ts::date
    THEN 1
    WHEN o.delivered_customer_ts IS NOT NULL AND o.estimated_delivery_ts IS NOT NULL
    THEN 0
  END AS on_time_flag

FROM stg.orders o;

ALTER TABLE mart.fact_orders
  ADD CONSTRAINT pk_fact_orders PRIMARY KEY (order_id);

CREATE INDEX IF NOT EXISTS ix_fact_orders_customer
  ON mart.fact_orders (customer_id);


-- 2.2 fact_order_items (line-item)

DROP TABLE IF EXISTS mart.fact_order_items;

CREATE TABLE mart.fact_order_items AS
SELECT
  oi.order_id,
  oi.order_item_id,
  oi.product_id,
  oi.seller_id,
  oi.shipping_limit_ts,
  oi.price,
  oi.freight_value,
  (COALESCE(oi.price,0) + COALESCE(oi.freight_value,0)) AS line_total
FROM stg.order_items oi;

CREATE INDEX IF NOT EXISTS ix_fact_items_order
  ON mart.fact_order_items (order_id);

CREATE INDEX IF NOT EXISTS ix_fact_items_seller
  ON mart.fact_order_items (seller_id);

CREATE INDEX IF NOT EXISTS ix_fact_items_product
  ON mart.fact_order_items (product_id);
