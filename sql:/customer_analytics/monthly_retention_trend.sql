WITH RECURSIVE calendar(month) AS (
    SELECT '2016-09'
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM calendar
    WHERE month < '2018-10'
),

customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

customer_type AS (
    SELECT 
        customer_unique_id,
        CASE 
            WHEN order_count = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS type
    FROM customer_orders
),

monthly_counts AS (
    SELECT 
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        ct.type,
        COUNT(DISTINCT c.customer_unique_id) AS customers
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    JOIN customer_type ct
        ON c.customer_unique_id = ct.customer_unique_id
    GROUP BY month, ct.type
),

types(type) AS (
    SELECT 'One-time'
    UNION ALL
    SELECT 'Repeat'
)

SELECT
    c.month,
    t.type,
    COALESCE(mc.customers, 0) AS customers
FROM calendar c
CROSS JOIN types t
LEFT JOIN monthly_counts mc
    ON c.month = mc.month AND t.type = mc.type
ORDER BY c.month, t.type;