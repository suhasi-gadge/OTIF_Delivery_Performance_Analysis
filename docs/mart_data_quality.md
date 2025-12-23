# Day 02 — Mart Data Quality & Validation Report  
**Project:** OTIF Delivery Performance Analysis (Olist E-Commerce)  
**Layer:** Analytics Mart (`mart` schema)  
**Objective:** Validate star schema integrity, KPI reliability, and data readiness for BI consumption.

---

## 1. Overview

On Day 02, the cleaned staging data (`stg`) was transformed into an analytics-ready **star schema** in the `mart` layer.  
This document captures all **data quality checks**, **sanity validations**, and **business logic confirmations** performed to ensure the mart is reliable for KPI reporting and dashboarding.

The mart layer includes:
- Dimension tables (`dim_customer`, `dim_seller`, `dim_product`, `dim_date`)
- Fact tables (`fact_orders`, `fact_order_items`)
- KPI views for delivery performance and root-cause analysis

---

## 2. Fact Table Integrity Checks

### 2.1 Primary Key Validity — `fact_orders`

**Checks performed:**
- Null primary keys
- Duplicate order IDs

**Results:**
- `order_id` null count: **0**
- Duplicate `order_id` rows: **0**

**Interpretation:**  
The `fact_orders` table has a clean 1-row-per-order grain with no structural integrity issues.

---

## 3. Timestamp Completeness Checks

Delivery performance KPIs depend heavily on timestamp availability. The following checks were performed:

### 3.1 Delivered vs Estimated Timestamp Null Rates

|      Timestamp          | Null Percentage |
|-------------------------|-----------------|
| `delivered_customer_ts` |    **2.98%**    |
| `estimated_delivery_ts` |    **0.00%**    |

**Interpretation:**
- Missing delivered timestamps are expected for canceled, unavailable, or in-progress orders.
- Estimated delivery timestamps are complete, enabling consistent late/on-time calculations.

**Conclusion:**  
Timestamp completeness is sufficient for reliable OTIF and delivery delay metrics.

---

## 4. Delivery Delay Distribution Sanity Checks

To validate delivery delay calculations, the distribution of `days_late` was analyzed.

### 4.1 Days Late Summary

|       Metric      |   Value    |
|-------------------|------------|
| Minimum days late |  **-147**  |
| Maximum days late |   **188**  |
| Average days late | **-11.88** |

**Interpretation:**
- Negative values indicate early delivery.
- Positive values indicate late delivery.
- Large negative values suggest conservative delivery estimates.
- Large positive values represent rare but extreme logistics delays.

These values align with known characteristics of the Olist dataset and do not indicate data corruption.

---

## 5. On-Time Rate Validation by Order Status

To ensure the on-time KPI is correctly scoped, on-time rate was evaluated by `order_status`.

### 5.1 Results

| Order Status | Orders  | On-Time Rate (%) |
|--------------|---------|------------------|
| Delivered    | ~96,470 |    **93.23%**    |
| Canceled     |    6    |    **83.33%**    |

**Interpretation:**
- The on-time delivery KPI primarily reflects delivered orders.
- The canceled order sample size is too small to be statistically meaningful.
- OTIF and on-time KPIs intentionally exclude canceled/unavailable orders.

**Conclusion:**  
The reported on-time rate of **93.23%** represents **delivered orders with valid delivery estimates**, which is the correct business interpretation.

---

## 6. Extreme Outlier Analysis (Early & Late Deliveries)

To assess whether extreme delivery delays could distort KPIs, additional outlier checks were performed.

### 6.1 Outlier Counts

|   Category       |   Orders  |
|------------------|-----------|
| Late ≥ 30 days   |  **360**  |
| Late ≥ 60 days   |  **84**   |
| Early ≤ -30 days | **2,732** |
| Early ≤ -60 days |   **36**  |

**Interpretation:**
- Severe late deliveries (≥ 60 days) are extremely rare (<0.1% of delivered orders).
- Early deliveries are more common, indicating conservative estimated delivery dates.
- Extreme early deliveries (≤ -60 days) are minimal and do not impact aggregate KPIs.

**Handling Strategy:**
- Outliers are **retained** in the dataset.
- They will be **flagged or capped** in Power BI visuals where appropriate, rather than removed.

---

## 7. KPI Readiness Assessment

Based on all checks performed:

|          Area            |           Status           |
|--------------------------|----------------------------|
| Fact table integrity     | ✅ Passed                  |
| Timestamp completeness   | ✅ Passed                  |
| Delay calculation sanity | ✅ Passed                  |
| On-time KPI logic        | ✅ Passed                  |
| Outlier behavior         | ✅ Understood & documented |

**Conclusion:**  
The mart layer is **analytics-ready** and suitable for:
- Executive OTIF dashboards
- Seller and lane performance analysis
- Root-cause investigation
- Customer experience impact analysis

---

## 8. Final Conclusion

All Day 02 objectives have been successfully met:

- Star schema tables are correctly built and validated
- KPI logic is consistent and defensible
- Data quality issues are identified, explained, and documented
- The dataset is ready for Power BI modeling and visualization

