SELECT
    COALESCE(
        t.product_category_name_english,
        NULLIF(p.product_category_name, ''),
        'Unknown'
    ) AS category,

    ROUND(AVG(oi.price),2) AS avg_price,

    COUNT(*) AS items_sold

FROM order_items oi

JOIN products p
ON oi.product_id=p.product_id

LEFT JOIN product_category_name_translation t
ON p.product_category_name=t.product_category_name

GROUP BY category

HAVING items_sold>=100

ORDER BY avg_price DESC;