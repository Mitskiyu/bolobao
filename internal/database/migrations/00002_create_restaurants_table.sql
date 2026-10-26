-- +goose Up
-- +goose StatementBegin
CREATE TABLE restaurants (
    id          UUID PRIMARY KEY DEFAULT uuidv7(),
    fsq_id      TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    category    TEXT NOT NULL,
    address     TEXT NOT NULL DEFAULT '',
    area        TEXT NOT NULL,
    locality    TEXT NOT NULL DEFAULT '',
    district    TEXT NOT NULL,
    district_zh TEXT NOT NULL,
    labels      TEXT[] NOT NULL,
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
