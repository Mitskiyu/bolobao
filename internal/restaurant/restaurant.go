package restaurant

import "uuid"

type restaurant struct {
	ID         uuid.UUID `json:"id"`
	Name       string    `json:"name"`
	Category   string    `json:"category"`
	Address    string    `json:"address"`
	Area       string    `json:"area"`
	Answers    []answer  `json:"answers"`
	PriceLevel *int      `json:"price_level"`
	Lat        float64   `json:"lat"`
	Lon        float64   `json:"lon"`
}

type answer struct {
	Prompt    prompt `json:"prompt"`
	Text      string `json:"text"`
	SourceUrl string `json:"source_url"`
}

type prompt string

const (
	BestDish                     prompt = "best_dish"
	WhatToOrderFirst             prompt = "what_to_order_first"
	OrderThisIfItsYourSecondTime prompt = "order_this_if_its_your_second_time"
	OrderThisNotThat             prompt = "order_this_not_that"
	WhatToSkip                   prompt = "what_to_skip"
	KnownFor                     prompt = "known_for"
	PortionSize                  prompt = "portion_size"
	ValueForMoney                prompt = "value_for_money"
	WorthTheQueue                prompt = "worth_the_queue"
	WaitTime                     prompt = "wait_time"
	Busy                         prompt = "busy"
	NeedToBook                   prompt = "need_to_book"
	OpeningHours                 prompt = "opening_hours"
	BestTime                     prompt = "best_time"
	Breakfast                    prompt = "breakfast"
	ServiceExperience            prompt = "service"
	HowOld                       prompt = "how_old"
	CashOnly                     prompt = "cash_only"
	ShareTable                   prompt = "share_table"
	GettingThere                 prompt = "getting_there"
	SpiceLevel                   prompt = "spice_level"
	Drinks                       prompt = "drinks"
	RoomVibe                     prompt = "room_vibe"
)
