-- name: ListRestaurants :many
SELECT id, name, category, address, area, answers, price_level, lat, lon
FROM restaurants
WHERE id > sqlc.arg(cursor)
ORDER BY id
LIMIT sqlc.arg(row_limit);
