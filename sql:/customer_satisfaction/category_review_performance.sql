SELECT
    COALESCE(
        t.product_category_name_english,
        NULLIF(p.product_category_name,''),
        'Unknown'
    ) AS category,

    COUNT(DISTINCT o.order_id) AS reviewed_orders,

    ROUND(AVG(r.review_score), 2) AS avg_review_score,

    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,

    SUM(CASE WHEN r.review_score = 5 THEN 1 ELSE 0 END) AS five_star_reviews

FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name

WHERE o.order_status = 'delivered'
GROUP BY category
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_review_score DESC;