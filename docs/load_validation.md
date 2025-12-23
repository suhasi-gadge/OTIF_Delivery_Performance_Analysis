# Day 01 — Raw Data Load Validation

## Objective
Ensure all source CSV files from the Olist dataset are successfully loaded into PostgreSQL with correct row counts and no missing primary identifiers.

---

## Raw Tables Loaded
The following tables were loaded into the `raw` schema:

- raw.customers
- raw.sellers
- raw.products
- raw.product_category_name_translation
- raw.orders
- raw.order_items
- raw.order_payments
- raw.order_reviews

---

## Row Count Validation

|               Table Name              | Row Count   |
|---------------------------------------|-------------|
| raw.customers                         | **99,442**  |
| raw.sellers                           |  **3,096**  |
| raw.products                          | **32,952**  |
| raw.product_category_name_translation |    **72**   |
| raw.orders                            | **99,442**  |
| raw.order_items                       | **112,651** |
| raw.order_payments                    | **103,887** |
| raw.order_reviews                     | **99,225**  |

---

## Data Quality Notes

- Initial CSV imports included header rows mistakenly ingested as data in some tables.
- These header rows were identified via invalid timestamp casting errors and removed explicitly.
- CSV encoding issues (BIG5 vs UTF-8) were resolved by enforcing UTF-8 encoding during import.

After corrections, all raw tables loaded successfully and passed basic sanity checks (non-null primary keys).
