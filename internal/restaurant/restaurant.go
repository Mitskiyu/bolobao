package restaurant

import "uuid"

type restaurant struct {
	ID         uuid.UUID `json:"id"`
	Name       string    `json:"name"`
	Category   string    `json:"category"`
	Address    string    `json:"address"`
	Area       string    `json:"area"`
	Lat        float64   `json:"lat"`
	Lon        float64   `json:"lon"`
	HasProfile bool      `json:"has_profile"`
}
