package restaurant

import (
	"context"
	"encoding/json"
	"fmt"
	"uuid"

	"munchmax/internal/database"
)

type store interface {
	ListRestaurants(ctx context.Context, arg database.ListRestaurantsParams) ([]database.ListRestaurantsRow, error)
}

type Service struct {
	store store
}

func NewService(store store) *Service {
	return &Service{
		store: store,
	}
}

func (s *Service) list(ctx context.Context, cursor uuid.UUID, limit int) ([]restaurant, error) {
	params := database.ListRestaurantsParams{
		Cursor:   cursor,
		RowLimit: int32(limit),
	}

	rests, err := s.store.ListRestaurants(ctx, params)
	if err != nil {
		return nil, err
	}

	out := make([]restaurant, 0, len(rests))
	for _, r := range rests {
		rest, err := fromRow(r)
		if err != nil {
			return nil, fmt.Errorf("failed to conv restaurant %s: %w", r.ID, err)
		}
		out = append(out, rest)
	}

	return out, nil
}

func fromRow(row database.ListRestaurantsRow) (restaurant, error) {
	r := restaurant{
		ID:       row.ID,
		Name:     row.Name,
		Category: row.Category,
		Address:  row.Address,
		Area:     row.Area,
		Lat:      row.Lat,
		Lon:      row.Lon,
	}

	if row.PriceLevel.Valid {
		p := int(row.PriceLevel.Int32)
		r.PriceLevel = &p
	}

	if err := json.Unmarshal(row.Answers, &r.Answers); err != nil {
		return restaurant{}, fmt.Errorf("unmarshal answers: %w", err)
	}

	return r, nil
}
