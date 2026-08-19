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
    JOIN order_payments p ON o.order_id = p.order_id
    GROUP BY month
)
SELECT
    c.month,
    COALESCE(mr.revenue, 0) AS revenue
FROM calendar c
LEFT JOIN monthly_revenue mr ON c.month = mr.month
ORDER BY c.month;
