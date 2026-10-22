-- name: ListRestaurants :many
WITH cur AS (
    SELECT score, id
    FROM restaurants
    WHERE id = sqlc.arg(cursor)::uuid
)

SELECT
    r.id, r.name, r.category, r.address, r.area,
    r.answers, r.score, r.price_level, r.lat, r.lon
FROM restaurants r
LEFT JOIN cur ON true
WHERE
    cur.id IS null
    OR r.score < cur.score
    OR (r.score = cur.score AND r.id > cur.id)
ORDER BY r.score DESC, r.id
LIMIT sqlc.arg(row_limit);
