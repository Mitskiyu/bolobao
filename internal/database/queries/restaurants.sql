-- name: GetFsqID :one
SELECT fsq_id
FROM restaurants
WHERE id = $1;

-- name: SearchRestaurants :many
SELECT
    r.id, r.name, r.category, r.address, r.area, r.lat, r.lon,
    (p.restaurant_id IS NOT NULL)::bool AS has_profile
FROM restaurants r
LEFT JOIN restaurant_profiles p ON p.restaurant_id = r.id
WHERE r.name ILIKE '%' || sqlc.arg(query)::text || '%'
ORDER BY length(r.name), r.name
LIMIT 20;
