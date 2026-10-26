-- +goose Up
-- +goose StatementBegin
CREATE TABLE restaurant_profiles (
    restaurant_id UUID PRIMARY KEY REFERENCES restaurants (id) ON DELETE CASCADE,
    answers       JSONB NOT NULL,
    score         FLOAT NOT NULL DEFAULT 0,
    price_level   INT CHECK (price_level BETWEEN 1 AND 4),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    modified_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER update_timestamp BEFORE
UPDATE ON restaurant_profiles FOR EACH ROW EXECUTE FUNCTION moddatetime(modified_at);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS restaurant_profiles;

-- +goose StatementEnd
