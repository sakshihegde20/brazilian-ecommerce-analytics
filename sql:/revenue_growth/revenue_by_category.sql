WITH order_totals AS (
    SELECT 
        order_id,
        SUM(price) AS total_price
    FROM order_items
    GROUP BY order_id
)

SELECT 
    CASE
        WHEN oi.order_id IS NULL THEN 'No Item Data'
        WHEN t.product_category_name_english IS NOT NULL
            THEN t.product_category_name_english
        WHEN pr.product_category_name IS NOT NULL
            AND pr.product_category_name <> ''
            THEN pr.product_category_name
        ELSE 'Unknown'
    END AS category,

    ROUND(SUM(
        CASE 
            WHEN oi.price IS NULL THEN p.payment_value
            ELSE (oi.price * 1.0 / ot.total_price) * p.payment_value
        END
    ), 2) AS revenue

FROM orders o
JOIN order_payments p 
    ON o.order_id = p.order_id
LEFT JOIN order_items oi 
    ON o.order_id = oi.order_id
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN products pr
    ON oi.product_id = pr.product_id
LEFT JOIN product_category_name_translation t
    ON pr.product_category_name = t.product_category_name

GROUP BY category
ORDER BY revenue DESC;