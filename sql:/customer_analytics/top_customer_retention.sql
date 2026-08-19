WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
),

ranked_customers AS (
    SELECT
        customer_unique_id,
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
),

customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    cs.customer_segment,

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN co.total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN co.total_orders > 1 THEN 1
                ELSE 0
            END
        ) /
        COUNT(*),
        2
    ) AS retention_rate

FROM customer_segments cs

JOIN customer_orders co
    ON cs.customer_unique_id = co.customer_unique_id

GROUP BY cs.customer_segment

ORDER BY
    CASE
        WHEN cs.customer_segment = 'Top 10%' THEN 1
        ELSE 2
    END;