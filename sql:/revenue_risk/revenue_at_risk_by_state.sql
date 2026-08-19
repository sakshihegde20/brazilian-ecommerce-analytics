SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date OR r.review_score <= 2 THEN oi.price ELSE 0 END), 2) AS revenue_at_risk
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY revenue_at_risk DESC;