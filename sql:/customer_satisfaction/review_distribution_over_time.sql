WITH RECURSIVE calendar(month) AS (
    SELECT '2016-09'
    UNION ALL
    SELECT STRFTIME('%Y-%m', DATE(month || '-01', '+1 month'))
    FROM calendar
    WHERE month < '2018-10'
),

monthly_reviews AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        COUNT(DISTINCT o.order_id) AS reviewed_orders,
        SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
        SUM(CASE WHEN r.review_score = 5 THEN 1 ELSE 0 END) AS five_star_reviews,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    GROUP BY month
)

SELECT
    c.month,
    COALESCE(mr.reviewed_orders, 0) AS reviewed_orders,
    COALESCE(mr.bad_reviews, 0) AS bad_reviews,
    COALESCE(mr.five_star_reviews, 0) AS five_star_reviews,
    mr.avg_review_score
FROM calendar c
LEFT JOIN monthly_reviews mr ON c.month = mr.month
ORDER BY c.month;