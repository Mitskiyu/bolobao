-- name: ListRestaurants :many
WITH cur AS (
    SELECT score, restaurant_id AS id
    FROM restaurant_profiles
    WHERE restaurant_id = sqlc.arg(cursor)::uuid
)

SELECT
    r.id, r.name, r.category, r.address, r.area,
    p.answers, p.score, p.price_level, r.lat, r.lon
FROM restaurants r
JOIN restaurant_profiles p ON p.restaurant_id = r.id
LEFT JOIN cur ON true
WHERE
    cur.id IS null
    OR p.score < cur.score
    OR (p.score = cur.score AND r.id > cur.id)
ORDER BY p.score DESC, r.id
LIMIT sqlc.arg(row_limit);
