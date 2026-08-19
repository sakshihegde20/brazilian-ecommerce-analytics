# Brazilian E-Commerce Analytics — SQL + Power BI

End-to-end analytics project on the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — raw transactional data taken through SQL transformation to a 6-page Power BI dashboard with DAX-driven KPIs, covering revenue growth, customer behavior, product performance, satisfaction, and revenue risk.

**23 SQL queries** across 5 analysis areas → curated CSV outputs → Power BI semantic model with custom DAX measures → business-ready dashboard.

---

## Headline Numbers

| Total Revenue | Total Orders | Avg Order Value | Repeat Customer Rate | Revenue at Risk |
|---|---|---|---|---|
| R$16.01M | 99,441 | R$160.99 | 3.12% | R$2.49M (~15.5%) |

---

## Dashboard

**Executive Overview**

![Executive Overview](images/executive-overview.png)

**Revenue & Growth Analysis**

![Revenue Growth](images/revenue-growth-analysis.png)

**Customer Analytics**

![Customer Analytics](images/customer-analytics.png)

**Product Analytics**

![Product Analytics](images/product-analytics.png)

**Customer Satisfaction**

![Customer Satisfaction](images/customer-satisfaction.png)

**Revenue Risk & Business Insights**

![Revenue Risk](images/revenue-risk-business-insights.png)

---

---

## Business Questions

The analysis was built around five core business questions:

1. **Revenue & Growth** — How is revenue changing over time, and where are the major growth or decline periods?
2. **Customer Behavior** — How much revenue comes from repeat customers, and how concentrated is spending among high-value customers?
3. **Product Performance** — Which categories combine volume, pricing, and revenue strength, and where are the premium/niche opportunities?
4. **Customer Satisfaction** — How do delivery delays relate to customer reviews, and which categories or states show weaker satisfaction?
5. **Revenue Risk** — Which categories, states, sellers, and customers represent the greatest revenue exposure?

## Key Insights

- **Retention is the core problem.** Only 3.12% of customers (2,997 of 96,096) make a repeat purchase — the rest buy once and never return.
- **Revenue is concentrated at the top.** The top 10% of customers by spend generate 38.51% of total revenue (R$6.17M) and retain at 4.04x the rate of the other 90% — they're worth protecting disproportionately.
- **Delivery delays are strongly associated with lower satisfaction.** On-time orders average a 4.29 review score; orders delivered 4–7 days late average 2.17 — a 1.72-point gap between on-time and late deliveries.
- **That risk has a dollar value, measured two ways.** R$2.49M in order-level revenue (~15.5% of total) is associated with orders that were either delivered late or rated poorly. A separate seller-level analysis — restricted to sellers with ≥30 orders — finds R$1.86M (~11.6% of total revenue) exposed, concentrated among a smaller set of higher-risk sellers and categories such as watches_gifts and computers_accessories.
- **The dataset's own coverage boundary is visible in the data** (near-zero orders before Oct 2016, sharp drop after Sep 2018) — handled explicitly in the dashboard with footnotes rather than left to look like a business event.

---

## Skills Demonstrated

**SQL**
- Recursive CTEs (calendar-spine generation for month-over-month trend tables)
- Window functions — `NTILE()` for customer decile segmentation, `LAG()` for month-over-month growth calculations
- Multi-table joins with explicit null-handling (orders without reviews, orders without item records)
- Aggregate risk-scoring logic combining delivery lateness and review sentiment into a single "revenue at risk" measure

**Power BI / DAX**
- Star-schema-style semantic model across 23 curated tables with defined relationships
- Custom DAX measures: `Latest Month Growth %`, `Average Growth % (Stable)`, `Cumulative Spend %`, `Top10 Retention Multiplier`, `Category Deviation from Overall`, `Total Seller Revenue at Risk`
- Direct Lake connectivity to a Microsoft Fabric Lakehouse
- 6-page report design with interactive cross-filtering across pages and visuals, footnoted caveats, and KPI cards

## Example SQL

**Customer decile segmentation (window function):**
```sql
WITH customer_spend AS (
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments op ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_spent,
    NTILE(10) OVER (ORDER BY total_spent DESC) AS decile
FROM customer_spend;
```

**Calendar-spine recursive CTE (for month-over-month trend tables):**
```sql
WITH RECURSIVE month_series AS (
    SELECT CAST('2016-09' AS VARCHAR) AS month
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM month_series
    WHERE month < '2018-10'
)
SELECT * FROM month_series;
```

See the [`sql/`](./sql/) directory for all 23 queries, organized by analysis area.

---

## Repository Structure

```
├── sql/                  # 23 SQL queries, grouped by analysis area
│   ├── revenue_growth/
│   ├── customer_analytics/
│   ├── customer_satisfaction/
│   ├── product_analytics/
│   └── revenue_risk/
├── output/               # CSV output for each query (same grouping)
├── images/               # Dashboard page exports (PNG)
├── powerbi/              # Power BI report (.pbix)
└── report/               # Full dashboard export (PDF)
```

---

## Data Source

Raw data: [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) — 9 relational tables, ~100K orders, Sep 2016–Oct 2018. Not included in this repo due to size (~126MB); download directly from Kaggle to reproduce.

## Tools

SQL (SQLite, via DB Browser for SQLite), Microsoft Power BI, Microsoft Fabric (Lakehouse, Direct Lake), DAX.

---

## Reproducing the Analysis

1. Download the raw dataset from Kaggle (link above).
2. Load the 9 raw tables into SQLite.
3. Run the queries in `sql/` to reproduce each analytical output.
4. Reference outputs are already provided in `output/` if you want to skip straight to comparing results.
5. The Power BI report and PDF export are in `powerbi/` and `report/`. The `.pbix` requires the original Fabric Lakehouse environment for live Direct Lake connectivity — the PDF and screenshots above are the portable, authoritative version of the final dashboard.

---

## Notes & Limitations

- **Categories Tracked (75)** on the Product Analytics page includes two non-product buckets ("Unknown" and "No Item Data") from the revenue table, alongside 74 real product categories. Units Sold and pricing visuals reflect the 74 real categories only.
- **The `.pbix` file uses Direct Lake mode** against a Microsoft Fabric Lakehouse on a trial workspace. It will not render live data outside that environment — the PDF export and screenshots above reflect the fully working dashboard and are the authoritative source for the analysis.
- **Minor non-determinism:** `customer_segmentation_ntile` uses `NTILE(10) OVER (ORDER BY total_spent DESC)` with no tiebreaker, so ~0.04% of customers near decile boundaries can shift between adjacent deciles on re-run. This has a small (<2%) cascading effect on two dependent risk tables. Immaterial to the analysis, noted here for transparency.
