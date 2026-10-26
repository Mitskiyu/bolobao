package restaurant

import (
	"context"
	"encoding/json"
	"fmt"
	"uuid"

	"bolobao/internal/database"
)

type store interface {
	ListProfiles(ctx context.Context, arg database.ListProfilesParams) ([]database.ListProfilesRow, error)
}

type Service struct {
	store store
}

func NewService(store store) *Service {
	return &Service{
		store: store,
	}
}

func (s *Service) listProfiles(ctx context.Context, cursor uuid.UUID, limit int) ([]profile, error) {
	params := database.ListProfilesParams{
		Cursor:   cursor,
		RowLimit: int32(limit),
	}

	rows, err := s.store.ListProfiles(ctx, params)
	if err != nil {
		return nil, err
	}

	out := make([]profile, 0, len(rows))
	for _, r := range rows {
		p, err := fromRow(r)
		if err != nil {
			return nil, fmt.Errorf("failed to conv profile %s: %w", r.ID, err)
		}
		out = append(out, p)
	}

	return out, nil
}

func fromRow(row database.ListProfilesRow) (profile, error) {
	r := profile{
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
		return profile{}, fmt.Errorf("unmarshal answers: %w", err)
	}

	return r, nil
}
