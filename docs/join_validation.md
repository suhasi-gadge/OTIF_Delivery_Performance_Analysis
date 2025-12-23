# Day 01 — Staging Layer & Join Validation

## Objective
Validate that cleaned staging tables in the `stg` schema:
- Contain correctly typed data
- Preserve referential integrity
- Support downstream analytics without join issues

---

## Staging Tables Created

The following staging tables were created with minimal cleaning and type casting:

- stg.customers
- stg.sellers
- stg.products
- stg.category_translation
- stg.orders
- stg.order_items
- stg.order_payments
- stg.order_reviews_dedup (1 review per order)

Key transformations included:
- Casting timestamps and numeric fields
- Trimming strings and handling blanks
- Deduplicating reviews using latest review per order

---

## Staging Row Counts

|       Table Name        | Row Count   |
|-------------------------|-------------|
| stg.customers           | **99,442**  |
| stg.sellers             | **3,096**   |
| stg.products            | **32,952**  |
| stg.orders              | **99,441**  |
| stg.order_items         | **112,650** |
| stg.order_reviews_dedup | **98,673**  |

---

## Join Coverage Results

|    Join Relationship   | Coverage / Result |
|------------------------|-------------------|
| orders ↔ customers     |         100%      |
| orders ↔ order_items   |      99.22%       |
| order_items ↔ sellers  |     0% missing    |
| order_items ↔ products |     0% missing    |
| orders ↔ reviews_dedup |      99.23%       |

---

## Interpretation & Business Context

- **Orders → Customers (100%)**  
  Every order is associated with a valid customer, confirming clean primary keys.

- **Orders → Order Items (99.22%)**  
  A small fraction of orders do not have line items. Investigation showed these are primarily canceled or unavailable orders, which is expected behavior in e-commerce systems.

- **Order Items → Sellers / Products (0% missing)**  
  All line items map cleanly to sellers and products, indicating complete dimensional coverage.

- **Orders → Reviews (99.23%)**  
  Review coverage is high, which aligns with known characteristics of the Olist dataset. Deduplication ensured one review per order.

---

## Conclusion

The staging layer successfully preserves data integrity and supports reliable joins across all core entities.  
This validates the dataset for downstream KPI computation and dashboard development in subsequent project stages.
