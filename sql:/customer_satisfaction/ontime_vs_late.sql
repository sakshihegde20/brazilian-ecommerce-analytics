SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,

    COUNT(DISTINCT o.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,

    ROUND(SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS bad_review_pct,
    ROUND(SUM(CASE WHEN r.review_score = 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS five_star_pct

FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status
ORDER BY CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 2 END;