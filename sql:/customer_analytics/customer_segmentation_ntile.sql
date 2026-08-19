WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_spent,
    NTILE(10) OVER (
        ORDER BY total_spent DESC
    ) AS decile
FROM customer_revenue;