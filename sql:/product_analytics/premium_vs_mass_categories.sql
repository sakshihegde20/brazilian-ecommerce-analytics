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

category_revenue AS (
    SELECT
        cs.customer_segment,

        COALESCE(
            t.product_category_name_english,
            NULLIF(pr.product_category_name, ''),
            'Unknown'
        ) AS category,

        SUM(oi.price) AS revenue

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN customer_segments cs
        ON c.customer_unique_id = cs.customer_unique_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products pr
        ON oi.product_id = pr.product_id

    LEFT JOIN product_category_name_translation t
        ON pr.product_category_name = t.product_category_name

    GROUP BY
        cs.customer_segment,
        category
)

SELECT
    category,

    ROUND(
        SUM(CASE
                WHEN customer_segment = 'Top 10%'
                THEN revenue
                ELSE 0
            END),
        2
    ) AS top10_revenue,

    ROUND(
        SUM(CASE
                WHEN customer_segment = 'Other 90%'
                THEN revenue
                ELSE 0
            END),
        2
    ) AS other90_revenue,

    ROUND(
        100.0 *
        SUM(CASE
                WHEN customer_segment = 'Top 10%'
                THEN revenue
                ELSE 0
            END)
        /
        NULLIF(SUM(revenue), 0),
        2
    ) AS pct_revenue_from_top10

FROM category_revenue

GROUP BY category

ORDER BY pct_revenue_from_top10 DESC;