WITH RECURSIVE calendar(month) AS (
    SELECT '2016-09'
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM calendar
    WHERE month < '2018-10'
),

categories AS (
    SELECT DISTINCT
        COALESCE(
            t.product_category_name_english,
            NULLIF(p.product_category_name, ''),
            'Unknown'
        ) AS category
    FROM products p
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
),

monthly_revenue AS (
    SELECT 
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        COALESCE(t.product_category_name_english, NULLIF(p.product_category_name, ''), 'Unknown') AS category,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY month, category
)

SELECT
    c.month,
    cat.category,
    mr.revenue
FROM calendar c
CROSS JOIN categories cat
LEFT JOIN monthly_revenue mr
    ON c.month = mr.month AND cat.category = mr.category
ORDER BY 
    c.month,
    cat.category;