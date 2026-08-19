WITH delivery_delay AS (
    SELECT
        o.order_id,
        JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_estimated_delivery_date) AS days_late
    FROM orders o
    WHERE o.order_delivered_customer_date IS NOT NULL
)
SELECT
    CASE
        WHEN days_late <= 0 THEN 'On Time'
        WHEN days_late BETWEEN 1 AND 3 THEN '1–3 Days Late'
        WHEN days_late BETWEEN 4 AND 7 THEN '4–7 Days Late'
        ELSE 'Over 1 Week Late'
    END AS lateness_bucket,

    COUNT(DISTINCT d.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews

FROM delivery_delay d
JOIN order_reviews r ON d.order_id = r.order_id
GROUP BY lateness_bucket
ORDER BY
    CASE
        WHEN lateness_bucket = 'On Time' THEN 1
        WHEN lateness_bucket = '1–3 Days Late' THEN 2
        WHEN lateness_bucket = '4–7 Days Late' THEN 3
        ELSE 4
    END;