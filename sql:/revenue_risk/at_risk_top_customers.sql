WITH customer_revenue AS (
    SELECT c.customer_unique_id, SUM(p.payment_value) AS total_spent
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_payments p ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
),
ranked_customers AS (
    SELECT customer_unique_id, total_spent, NTILE(10) OVER (ORDER BY total_spent DESC) AS decile
    FROM customer_revenue
),
top_customers AS (
    SELECT customer_unique_id, total_spent FROM ranked_customers WHERE decile = 1
),
customer_experience AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        SUM(oi.price) AS order_value,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS is_late,
        CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END AS is_bad_review
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id, o.order_id
)
SELECT
    ce.customer_unique_id,
    COUNT(*) AS risky_orders,
    ROUND(SUM(ce.order_value),2) AS revenue_at_risk,
    MAX(tc.total_spent) AS lifetime_customer_value
FROM customer_experience ce
JOIN top_customers tc ON ce.customer_unique_id = tc.customer_unique_id
WHERE ce.is_late = 1 OR ce.is_bad_review = 1
GROUP BY ce.customer_unique_id
ORDER BY revenue_at_risk DESC;