-- SET search_path TO raw, stg, mart, public;

-- RAW = minimal typing, no transformations

DROP TABLE IF EXISTS raw.customers;
CREATE TABLE raw.customers (
  customer_id TEXT,
  customer_unique_id TEXT,
  customer_zip_code_prefix TEXT,
  customer_city TEXT,
  customer_state TEXT
);

DROP TABLE IF EXISTS raw.sellers;
CREATE TABLE raw.sellers (
  seller_id TEXT,
  seller_zip_code_prefix TEXT,
  seller_city TEXT,
  seller_state TEXT
);

DROP TABLE IF EXISTS raw.products;
CREATE TABLE raw.products (
  product_id TEXT,
  product_category_name TEXT,
  product_name_lenght TEXT,
  product_description_lenght TEXT,
  product_photos_qty TEXT,
  product_weight_g TEXT,
  product_length_cm TEXT,
  product_height_cm TEXT,
  product_width_cm TEXT
);

DROP TABLE IF EXISTS raw.product_category_name_translation;
CREATE TABLE raw.product_category_name_translation (
  product_category_name TEXT,
  product_category_name_english TEXT
);

DROP TABLE IF EXISTS raw.orders;
CREATE TABLE raw.orders (
  order_id TEXT,
  customer_id TEXT,
  order_status TEXT,
  order_purchase_timestamp TEXT,
  order_approved_at TEXT,
  order_delivered_carrier_date TEXT,
  order_delivered_customer_date TEXT,
  order_estimated_delivery_date TEXT
);

DROP TABLE IF EXISTS raw.order_items;
CREATE TABLE raw.order_items (
  order_id TEXT,
  order_item_id TEXT,
  product_id TEXT,
  seller_id TEXT,
  shipping_limit_date TEXT,
  price TEXT,
  freight_value TEXT
);

DROP TABLE IF EXISTS raw.order_payments;
CREATE TABLE raw.order_payments (
  order_id TEXT,
  payment_sequential TEXT,
  payment_type TEXT,
  payment_installments TEXT,
  payment_value TEXT
);

DROP TABLE IF EXISTS raw.order_reviews;
CREATE TABLE raw.order_reviews (
  review_id TEXT,
  order_id TEXT,
  review_score TEXT,
  review_comment_title TEXT,
  review_comment_message TEXT,
  review_creation_date TEXT,
  review_answer_timestamp TEXT
);





