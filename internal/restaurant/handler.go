package restaurant

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
	"uuid"

	"bolobao/internal/httpx"
)

const (
	defaultLimit  = 20
	maxLimit      = 100
	streamTimeout = 3 * time.Minute
	minQuery      = 2
	maxQuery      = 100
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

func (h *Handler) CreateProfile(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(
		context.WithoutCancel(r.Context()),
		streamTimeout,
	)
	defer cancel()

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		httpx.Error(w, "INVALID_ID", "invalid id", http.StatusBadRequest)
		return
	}

	events, err := h.service.createProfile(ctx, id)
	if errors.Is(err, errNotFound) {
		httpx.Error(w, "NOT_FOUND", "restaurant not found", http.StatusNotFound)
		return
	}

	if errors.Is(err, errLimited) {
		httpx.Error(w, "RATE_LIMITED", "too many profiles today", http.StatusTooManyRequests)
		return
	}

	if err != nil {
		log.Printf("%v at %s", err, r.URL)
		httpx.Error(w, "UNAVAILABLE", "service unavailable", http.StatusServiceUnavailable)
		return
	}

	rc := http.NewResponseController(w)
	if err := rc.SetWriteDeadline(time.Now().Add(streamTimeout)); err != nil {
		log.Printf("%v at %s", err, r.URL)
	}

	header := w.Header()
	header.Set("Content-Type", "text/event-stream")
	header.Set("Cache-Control", "no-cache")
	w.WriteHeader(http.StatusOK)

	for e := range events {
		b, err := json.Marshal(e)
		if err != nil {
			log.Printf("%v at %s", err, r.URL)
			continue
		}

		_, _ = fmt.Fprintf(w, "data: %s\n\n", b)
		_ = rc.Flush()
	}
}

func (h *Handler) ListProfiles(w http.ResponseWriter, r *http.Request) {
	type res struct {
		Data []profile `json:"data"`
	}

	ctx := r.Context()
	params := r.URL.Query()

	cur, err := parseCursor(params)
	if err != nil {
		httpx.Error(w, "INVALID_CURSOR", err.Error(), http.StatusBadRequest)
		return
	}

	limit, err := parseLimit(params)
	if err != nil {
		httpx.Error(w, "INVALID_LIMIT", err.Error(), http.StatusBadRequest)
		return
	}

	profiles, err := h.service.listProfiles(ctx, cur, limit)
	if err != nil {
		log.Printf("%v at %s", err, r.URL)
		httpx.Error(w, "INTERNAL_ERROR", "internal server error", http.StatusInternalServerError)
		return
	}

	httpx.Write(w, res{Data: profiles}, http.StatusOK)
}

func (h *Handler) SearchRestaurants(w http.ResponseWriter, r *http.Request) {
	type res struct {
		Data []restaurant `json:"data"`
	}

	ctx := r.Context()
	q := strings.TrimSpace(r.URL.Query().Get("q"))

	if n := utf8.RuneCountInString(q); n < minQuery || n > maxQuery {
		httpx.Error(
			w,
			"INVALID_QUERY",
			fmt.Sprintf("q must be between %d and %d characters", minQuery, maxQuery),
			http.StatusBadRequest,
		)
		return
	}

	restaurants, err := h.service.searchRestaurants(ctx, q)
	if err != nil {
		log.Printf("%v at %s", err, r.URL)
		httpx.Error(w, "INTERNAL_ERROR", "internal server error", http.StatusInternalServerError)
		return
	}

	httpx.Write(w, res{Data: restaurants}, http.StatusOK)
}

func parseCursor(q url.Values) (uuid.UUID, error) {
	s := q.Get("after")
	if s == "" {
		return uuid.Nil(), nil
	}

	cur, err := uuid.Parse(s)
	if err != nil {
		return uuid.Nil(), fmt.Errorf("invalid cursor: %q", s)
	}

	return cur, nil
}

func parseLimit(q url.Values) (int, error) {
	s := q.Get("limit")
	if s == "" {
		return defaultLimit, nil
	}

	n, err := strconv.Atoi(s)
	if err != nil {
		return 0, fmt.Errorf("invalid limit: %q", s)
	}

	if n < 1 || n > maxLimit {
		return 0, fmt.Errorf("limit must be between 1 and %d", maxLimit)
	}

	return n, nil
}
