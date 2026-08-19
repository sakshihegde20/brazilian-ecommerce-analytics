WITH RECURSIVE calendar(month) AS (
    SELECT '2016-09'
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM calendar
    WHERE month < '2018-10'
),
order_counts AS (
    SELECT
        STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
        COUNT(DISTINCT order_id) AS orders
    FROM orders
    GROUP BY month
)
SELECT
    c.month,
    COALESCE(oc.orders, 0) AS orders
FROM calendar c
LEFT JOIN order_counts oc ON c.month = oc.month
ORDER BY c.month;