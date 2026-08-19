WITH RECURSIVE calendar(month) AS (
    SELECT '2016-09'
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM calendar
    WHERE month < '2018-10'
),

monthly_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(p.payment_value), 2) AS revenue
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY month
),

filled AS (
    SELECT
        c.month,
        COALESCE(mr.revenue, 0) AS revenue
    FROM calendar c
    LEFT JOIN monthly_revenue mr
        ON c.month = mr.month
),

lagged AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM filled
)

SELECT
    month,

    revenue,

    previous_month_revenue,

    ROUND(
        revenue - previous_month_revenue,
        2
    ) AS revenue_change,

    CASE
        WHEN previous_month_revenue IS NULL THEN NULL
        WHEN previous_month_revenue = 0 THEN NULL
        ELSE ROUND(
            (
                revenue - previous_month_revenue
            ) * 100.0 /
            previous_month_revenue,
            2
        )
    END AS growth_percentage

FROM lagged

ORDER BY month;