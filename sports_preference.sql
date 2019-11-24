/* Query 1 What Sports do Indians watch the most? 
(Has CTE's, Window func, aggregates, Case, to_tsquery) */

WITH t1
AS (  /* Subsets films rented by customers with address in India and categorized as sports */
    SELECT
        fi.film_id,
        fi.fulltext
    FROM customer AS cu
    JOIN address AS ad
        ON cu.address_id = ad.address_id
    JOIN city AS ci
        ON ad.city_id = ci.city_id
    JOIN country AS co
        ON ci.country_id = co.country_id
    JOIN rental AS re
        ON re.customer_id = cu.customer_id
    JOIN inventory AS inv
        ON re.inventory_id = inv.inventory_id
    JOIN film AS fi
        ON inv.film_id = fi.film_id
    JOIN film_category AS fc
        ON fi.film_id = fc.film_id
    JOIN category AS ca
        ON fc.category_id = ca.category_id
    WHERE co.country = 'India'
    AND ca.name = 'Sports'),

t2
AS ( /* Finds type of Sports Indian customers are watching from keywords in tsvector Film.fulltext */
    SELECT
        t1.film_id,
        CASE
            WHEN t1.fulltext @@ to_tsquery ('nfl | nba | mlb') = 'true' THEN 'American Sports'
            WHEN t1.fulltext @@ to_tsquery ('football | soccer') = 'true' THEN 'Soccer'
            WHEN t1.fulltext @@ to_tsquery ('cricket | frisbee | badminton') = 'true' THEN 'Lawn Sports'
            WHEN t1.fulltext @@ to_tsquery ('hunt | lumberjack') = 'true' THEN 'Outdoor Sports'
            WHEN t1.fulltext @@ to_tsquery ('drive') = 'true' THEN 'Motor Sports'
            WHEN t1.fulltext @@ to_tsquery ('baloon') = 'true' THEN 'Hot Air Balooning'
            WHEN t1.fulltext @@ to_tsquery ('wrestling') = 'true' THEN 'Wrestling'
            ELSE 'General Sports'
        END AS sport_type
    FROM t1)

/* Counts by type of sport and orders by most popular */
SELECT DISTINCT
    t2.sport_type AS "Sport Types",
    COUNT(t2.film_id) OVER (PARTITION BY t2.sport_type) AS 
    "Types of Sports Preferred by Customers from India"
FROM t1
JOIN T2
    ON t1.film_id = t2.film_id
ORDER BY 2 DESC;