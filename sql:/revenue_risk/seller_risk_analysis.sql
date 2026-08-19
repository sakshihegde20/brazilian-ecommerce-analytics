WITH seller_metrics AS (

    SELECT

        oi.seller_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) AS late_orders,

        SUM(
            CASE
                WHEN r.review_score <= 2
                THEN 1
                ELSE 0
            END
        ) AS bad_reviews,

        ROUND(AVG(r.review_score), 2) AS avg_review_score,

        ROUND(
            AVG(
                JULIANDAY(o.order_delivered_customer_date)
                -
                JULIANDAY(o.order_estimated_delivery_date)
            ),
            2
        ) AS avg_days_late,

        ROUND(
            SUM(
                CASE
                    WHEN o.order_delivered_customer_date >
                         o.order_estimated_delivery_date
                      OR r.review_score <= 2
                    THEN oi.price
                    ELSE 0
                END
            ),
            2
        ) AS revenue_at_risk

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    LEFT JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL

    GROUP BY oi.seller_id

)

SELECT *

FROM seller_metrics

WHERE total_orders >= 30
  AND revenue_at_risk > 0

ORDER BY revenue_at_risk DESC;