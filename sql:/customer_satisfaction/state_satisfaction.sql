SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews

FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_review_score DESC;