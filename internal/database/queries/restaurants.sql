-- name: GetFsqID :one
SELECT fsq_id
FROM restaurants
WHERE id = $1;
