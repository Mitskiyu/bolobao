package restaurant

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"iter"
	"net/http"
	"strings"
	"uuid"

	"bolobao/internal/database"

	"github.com/jackc/pgx/v5"
)

var errNotFound = errors.New("not found")

type store interface {
	ListProfiles(ctx context.Context, arg database.ListProfilesParams) ([]database.ListProfilesRow, error)
	GetFsqID(ctx context.Context, id uuid.UUID) (string, error)
}

type Service struct {
	store      store
	writerAddr string
	client     *http.Client
}

func NewService(store store, writerAddr string) *Service {
	return &Service{
		store:      store,
		writerAddr: writerAddr,
		client:     &http.Client{},
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

func (s *Service) createProfile(ctx context.Context, id uuid.UUID) (iter.Seq[event], error) {
	fsqID, err := s.store.GetFsqID(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}

	if err != nil {
		return nil, err
	}

	url := s.writerAddr + "/profiles/" + fsqID
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, nil)
	if err != nil {
		return nil, err
	}

	res, err := s.client.Do(req)
	if err != nil {
		return nil, err
	}

	if res.StatusCode != http.StatusOK {
		_ = res.Body.Close()
		return nil, fmt.Errorf("writer returned %s", res.Status)
	}

	events := func(yield func(event) bool) {
		defer func() { _ = res.Body.Close() }()

		sc := bufio.NewScanner(res.Body)
		for sc.Scan() {
			data, ok := strings.CutPrefix(sc.Text(), "data: ")
			if !ok {
				continue
			}

			var e event
			if err := json.Unmarshal([]byte(data), &e); err != nil {
				continue
			}

			if !yield(e) {
				return
			}
		}
	}

	return events, nil
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
