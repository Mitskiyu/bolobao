package server

import (
	"net/http"

	"bolobao/internal/restaurant"
)

type Handlers struct {
	Restaurant *restaurant.Handler
}

func routes(h Handlers) http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("OK"))
	})

	mux.HandleFunc("GET /profiles", h.Restaurant.ListProfiles)
	mux.HandleFunc("POST /restaurants/{id}/profile", h.Restaurant.CreateProfile)

	return mux
}
