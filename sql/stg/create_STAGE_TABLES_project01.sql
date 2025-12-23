/* ============================================================================
   Day 1 — Staging Layer Build (stg)
   Source: raw.*
   Target: stg.*
   Notes:
   - raw tables are TEXT-heavy; staging casts to proper types
   - minimal cleaning only (no business logic / KPIs yet)
   ============================================================================ */

BEGIN;

CREATE SCHEMA IF NOT EXISTS stg;

-- ---------- Helpers: drop existing staging tables (idempotent runs) ----------
DROP TABLE IF EXISTS stg.order_reviews_dedup;
DROP TABLE IF EXISTS stg.order_payments;
DROP TABLE IF EXISTS stg.order_items;
DROP TABLE IF EXISTS stg.orders;
DROP TABLE IF EXISTS stg.category_translation;
DROP TABLE IF EXISTS stg.products;
DROP TABLE IF EXISTS stg.sellers;
DROP TABLE IF EXISTS stg.customers;

-- ---------- stg.customers ----------
CREATE TABLE stg.customers AS
SELECT
  NULLIF(TRIM(customer_id), '')               AS customer_id,
  NULLIF(TRIM(customer_unique_id), '')        AS customer_unique_id,
  NULLIF(TRIM(customer_zip_code_prefix), '')  AS customer_zip_code_prefix,
  NULLIF(TRIM(customer_city), '')             AS customer_city,
  NULLIF(TRIM(customer_state), '')            AS customer_state
FROM raw.customers;

ALTER TABLE stg.customers
  ADD CONSTRAINT pk_stg_customers PRIMARY KEY (customer_id);

-- ---------- stg.sellers ----------
CREATE TABLE stg.sellers AS
SELECT
  NULLIF(TRIM(seller_id), '')               AS seller_id,
  NULLIF(TRIM(seller_zip_code_prefix), '')  AS seller_zip_code_prefix,
  NULLIF(TRIM(seller_city), '')             AS seller_city,
  NULLIF(TRIM(seller_state), '')            AS seller_state
FROM raw.sellers;

ALTER TABLE stg.sellers
  ADD CONSTRAINT pk_stg_sellers PRIMARY KEY (seller_id);

-- ---------- stg.category_translation ----------
CREATE TABLE stg.category_translation AS
SELECT
  NULLIF(TRIM(product_category_name), '')         AS product_category_name,
  NULLIF(TRIM(product_category_name_english), '') AS product_category_name_english
FROM raw.product_category_name_translation;

ALTER TABLE stg.category_translation
  ADD CONSTRAINT pk_stg_category_translation PRIMARY KEY (product_category_name);

-- ---------- stg.products ----------
CREATE TABLE stg.products AS
SELECT
  NULLIF(TRIM(product_id), '')                AS product_id,
  NULLIF(TRIM(product_category_name), '')     AS product_category_name,

  /* safe ints: cast only if numeric-like */
  CASE WHEN NULLIF(TRIM(product_name_lenght), '') ~ '^\d+$'
       THEN (TRIM(product_name_lenght))::INT END   AS product_name_length,

  CASE WHEN NULLIF(TRIM(product_description_lenght), '') ~ '^\d+$'
       THEN (TRIM(product_description_lenght))::INT END AS product_description_length,

  CASE WHEN NULLIF(TRIM(product_photos_qty), '') ~ '^\d+$'
       THEN (TRIM(product_photos_qty))::INT END     AS product_photos_qty,

  /* safe numerics */
  CASE WHEN NULLIF(TRIM(product_weight_g), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(product_weight_g))::NUMERIC END   AS product_weight_g,

  CASE WHEN NULLIF(TRIM(product_length_cm), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(product_length_cm))::NUMERIC END  AS product_length_cm,

  CASE WHEN NULLIF(TRIM(product_height_cm), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(product_height_cm))::NUMERIC END  AS product_height_cm,

  CASE WHEN NULLIF(TRIM(product_width_cm), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(product_width_cm))::NUMERIC END   AS product_width_cm
FROM raw.products;

ALTER TABLE stg.products
  ADD CONSTRAINT pk_stg_products PRIMARY KEY (product_id);

CREATE INDEX IF NOT EXISTS ix_stg_products_category
  ON stg.products (product_category_name);

-- ---------- stg.orders ----------
CREATE TABLE stg.orders AS
SELECT
  NULLIF(TRIM(order_id), '')       AS order_id,
  NULLIF(TRIM(customer_id), '')    AS customer_id,
  LOWER(NULLIF(TRIM(order_status), '')) AS order_status,

  /* timestamps: cast only if not blank */
  CASE WHEN NULLIF(TRIM(order_purchase_timestamp), '') IS NOT NULL
       THEN (TRIM(order_purchase_timestamp))::TIMESTAMP END AS purchase_ts,

  CASE WHEN NULLIF(TRIM(order_approved_at), '') IS NOT NULL
       THEN (TRIM(order_approved_at))::TIMESTAMP END AS approved_ts,

  CASE WHEN NULLIF(TRIM(order_delivered_carrier_date), '') IS NOT NULL
       THEN (TRIM(order_delivered_carrier_date))::TIMESTAMP END AS delivered_carrier_ts,

  CASE WHEN NULLIF(TRIM(order_delivered_customer_date), '') IS NOT NULL
       THEN (TRIM(order_delivered_customer_date))::TIMESTAMP END AS delivered_customer_ts,

  CASE WHEN NULLIF(TRIM(order_estimated_delivery_date), '') IS NOT NULL
       THEN (TRIM(order_estimated_delivery_date))::TIMESTAMP END AS estimated_delivery_ts
FROM raw.orders;

ALTER TABLE stg.orders
  ADD CONSTRAINT pk_stg_orders PRIMARY KEY (order_id);

CREATE INDEX IF NOT EXISTS ix_stg_orders_customer
  ON stg.orders (customer_id);

CREATE INDEX IF NOT EXISTS ix_stg_orders_purchase_ts
  ON stg.orders (purchase_ts);

-- ---------- stg.order_items ----------
CREATE TABLE stg.order_items AS
SELECT
  NULLIF(TRIM(order_id), '')     AS order_id,

  CASE WHEN NULLIF(TRIM(order_item_id), '') ~ '^\d+$'
       THEN (TRIM(order_item_id))::INT END   AS order_item_id,

  NULLIF(TRIM(product_id), '')   AS product_id,
  NULLIF(TRIM(seller_id), '')    AS seller_id,

  CASE WHEN NULLIF(TRIM(shipping_limit_date), '') IS NOT NULL
       THEN (TRIM(shipping_limit_date))::TIMESTAMP END AS shipping_limit_ts,

  CASE WHEN NULLIF(TRIM(price), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(price))::NUMERIC END        AS price,

  CASE WHEN NULLIF(TRIM(freight_value), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(freight_value))::NUMERIC END AS freight_value
FROM raw.order_items;

CREATE INDEX IF NOT EXISTS ix_stg_order_items_order
  ON stg.order_items (order_id);

CREATE INDEX IF NOT EXISTS ix_stg_order_items_seller
  ON stg.order_items (seller_id);

CREATE INDEX IF NOT EXISTS ix_stg_order_items_product
  ON stg.order_items (product_id);

-- ---------- stg.order_payments (recommended for later KPIs) ----------
CREATE TABLE stg.order_payments AS
SELECT
  NULLIF(TRIM(order_id), '') AS order_id,

  CASE WHEN NULLIF(TRIM(payment_sequential), '') ~ '^\d+$'
       THEN (TRIM(payment_sequential))::INT END AS payment_sequential,

  LOWER(NULLIF(TRIM(payment_type), '')) AS payment_type,

  CASE WHEN NULLIF(TRIM(payment_installments), '') ~ '^\d+$'
       THEN (TRIM(payment_installments))::INT END AS payment_installments,

  CASE WHEN NULLIF(TRIM(payment_value), '') ~ '^\d+(\.\d+)?$'
       THEN (TRIM(payment_value))::NUMERIC END AS payment_value
FROM raw.order_payments;

CREATE INDEX IF NOT EXISTS ix_stg_order_payments_order
  ON stg.order_payments (order_id);

-- ---------- stg.order_reviews_dedup ----------
/* Keep 1 review per order:
   - choose latest by review_creation_date, tie-breaker by review_answer_timestamp
*/
CREATE TABLE stg.order_reviews_dedup AS
WITH ranked AS (
  SELECT
    NULLIF(TRIM(review_id), '') AS review_id,
    NULLIF(TRIM(order_id), '')  AS order_id,

    CASE WHEN NULLIF(TRIM(review_score), '') ~ '^\d+$'
         THEN (TRIM(review_score))::INT END AS review_score,

    NULLIF(TRIM(review_comment_title), '')    AS review_comment_title,
    NULLIF(TRIM(review_comment_message), '')  AS review_comment_message,

    CASE WHEN NULLIF(TRIM(review_creation_date), '') IS NOT NULL
         THEN (TRIM(review_creation_date))::TIMESTAMP END AS review_creation_ts,

    CASE WHEN NULLIF(TRIM(review_answer_timestamp), '') IS NOT NULL
         THEN (TRIM(review_answer_timestamp))::TIMESTAMP END AS review_answer_ts,

    ROW_NUMBER() OVER (
      PARTITION BY NULLIF(TRIM(order_id), '')
      ORDER BY
        CASE WHEN NULLIF(TRIM(review_creation_date), '') IS NOT NULL
             THEN (TRIM(review_creation_date))::TIMESTAMP END DESC NULLS LAST,
        CASE WHEN NULLIF(TRIM(review_answer_timestamp), '') IS NOT NULL
             THEN (TRIM(review_answer_timestamp))::TIMESTAMP END DESC NULLS LAST
    ) AS rn
  FROM raw.order_reviews
  WHERE NULLIF(TRIM(order_id), '') IS NOT NULL
)
SELECT
  review_id,
  order_id,
  review_score,
  review_comment_title,
  review_comment_message,
  review_creation_ts,
  review_answer_ts
FROM ranked
WHERE rn = 1;

CREATE INDEX IF NOT EXISTS ix_stg_reviews_order
  ON stg.order_reviews_dedup (order_id);

COMMIT;

-- In case the COMMIT fails, try to fix issues in raw and then rollback and rerun. (encountered timestamp related error)
-- ROLLBACK;
-- SELECT 1;


-- To check if all the tables exist
-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'stg'
-- ORDER BY table_name;
