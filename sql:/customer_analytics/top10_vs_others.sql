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
),

ranked_customers AS (
    SELECT
        customer_unique_id,
        total_spent,
        NTILE(10) OVER (ORDER BY total_spent DESC) AS decile
    FROM customer_revenue
),

customer_segments AS (
    SELECT
        customer_unique_id,
        CASE
            WHEN decile = 1 THEN 'Top 10%'
            ELSE 'Other 90%'
        END AS customer_segment
    FROM ranked_customers
)

SELECT
    cs.customer_segment,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(p.payment_value), 2) AS total_revenue,

    ROUND(
        SUM(p.payment_value) * 1.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value

FROM orders o

JOIN order_payments p
    ON o.order_id = p.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN customer_segments cs
    ON c.customer_unique_id = cs.customer_unique_id

GROUP BY cs.customer_segment

ORDER BY
    CASE
        WHEN cs.customer_segment = 'Top 10%' THEN 1
        ELSE 2
    END;