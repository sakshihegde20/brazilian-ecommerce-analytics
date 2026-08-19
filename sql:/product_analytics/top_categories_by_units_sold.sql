SELECT
    COALESCE(
        t.product_category_name_english,
        NULLIF(p.product_category_name, ''),
        'Unknown'
    ) AS category,

    COUNT(*) AS units_sold,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price),2) AS revenue

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

GROUP BY category

ORDER BY units_sold DESC;