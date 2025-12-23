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

| Table Name | Row Count |
|-----------|----------|
| raw.customers | ⬅️ paste |
| raw.sellers | ⬅️ paste |
| raw.products | ⬅️ paste |
| raw.product_category_name_translation | ⬅️ paste |
| raw.orders | ⬅️ paste |
| raw.order_items | ⬅️ paste |
| raw.order_payments | ⬅️ paste |
| raw.order_reviews | ⬅️ paste |

---

## Data Quality Notes

- Initial CSV imports included header rows mistakenly ingested as data in some tables.
- These header rows were identified via invalid timestamp casting errors and removed explicitly.
- CSV encoding issues (BIG5 vs UTF-8) were resolved by enforcing UTF-8 encoding during import.

After corrections, all raw tables loaded successfully and passed basic sanity checks (non-null primary keys).
