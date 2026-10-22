-- +goose Up
-- +goose StatementBegin
CREATE TABLE restaurants (
    id          UUID PRIMARY KEY DEFAULT uuidv7(),
    fsq_id      TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    category    TEXT NOT NULL,
    address     TEXT NOT NULL DEFAULT '',
    area        TEXT NOT NULL,
    answers     JSONB NOT NULL,
    score       FLOAT NOT NULL DEFAULT 0,
    price_level INT CHECK (price_level BETWEEN 1 AND 4),
    lat         DOUBLE PRECISION NOT NULL,
    lon         DOUBLE PRECISION NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    modified_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_timestamp BEFORE
UPDATE ON restaurants FOR EACH ROW EXECUTE FUNCTION moddatetime(modified_at);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS restaurants;

-- +goose StatementEnd
