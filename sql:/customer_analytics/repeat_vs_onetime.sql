WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS num_customers
FROM customer_orders
GROUP BY customer_type;