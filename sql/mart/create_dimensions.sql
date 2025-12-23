-- 1.1 dim_customer 

DROP TABLE IF EXISTS mart.dim_customer;
CREATE TABLE mart.dim_customer AS
SELECT
  customer_id,
  customer_unique_id,
  customer_city,
  customer_state,
  customer_zip_code_prefix
FROM stg.customers;

ALTER TABLE mart.dim_customer
  ADD CONSTRAINT pk_dim_customer PRIMARY KEY (customer_id);

-- 1.2 dim_seller

DROP TABLE IF EXISTS mart.dim_seller;
CREATE TABLE mart.dim_seller AS
SELECT
  seller_id,
  seller_city,
  seller_state,
  seller_zip_code_prefix
FROM stg.sellers;

ALTER TABLE mart.dim_seller
  ADD CONSTRAINT pk_dim_seller PRIMARY KEY (seller_id);


-- 1.3 dim_product (with English category)

DROP TABLE IF EXISTS mart.dim_product;
CREATE TABLE mart.dim_product AS
SELECT
  p.product_id,
  p.product_category_name,
  COALESCE(ct.product_category_name_english, 'unknown') AS product_category_english,
  p.product_name_length,
  p.product_description_length,
  p.product_photos_qty,
  p.product_weight_g,
  p.product_length_cm,
  p.product_height_cm,
  p.product_width_cm
FROM stg.products p
LEFT JOIN stg.category_translation ct
  ON p.product_category_name = ct.product_category_name;

ALTER TABLE mart.dim_product
  ADD CONSTRAINT pk_dim_product PRIMARY KEY (product_id);


-- 1.4 dim_date (generate date range)

DROP TABLE IF EXISTS mart.dim_date;

WITH bounds AS (
  SELECT
    MIN(purchase_ts::date) AS min_date,
    MAX(purchase_ts::date) AS max_date
  FROM stg.orders
  WHERE purchase_ts IS NOT NULL
)
SELECT
  d::date AS date,
  EXTRACT(YEAR FROM d)::int AS year,
  EXTRACT(MONTH FROM d)::int AS month,
  TO_CHAR(d, 'Mon') AS month_name,
  EXTRACT(QUARTER FROM d)::int AS quarter,
  EXTRACT(WEEK FROM d)::int AS week_of_year,
  EXTRACT(DOW FROM d)::int AS day_of_week,
  TO_CHAR(d, 'Day') AS day_name,
  (d = d::date) AS is_date -- trivial but sometimes useful
INTO mart.dim_date
FROM bounds,
     generate_series(bounds.min_date, bounds.max_date, interval '1 day') AS d;

ALTER TABLE mart.dim_date
  ADD CONSTRAINT pk_dim_date PRIMARY KEY (date);

  