WITH RECURSIVE calendar(month) AS (
    SELECT '2016-09'
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM calendar
    WHERE month < '2018-10'
),

monthly_stats AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        SUM(p.payment_value) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY month
)

SELECT
    c.month,
    ROUND(
        ms.revenue * 1.0 /
        NULLIF(ms.orders, 0),
        2
    ) AS avg_order_value
FROM calendar c
LEFT JOIN monthly_stats ms
ON c.month = ms.month
ORDER BY c.month;