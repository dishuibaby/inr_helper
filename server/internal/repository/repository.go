package repository

import (
	"time"

	"warfarin-inr-demo/server/internal/model"
)

type Repository interface {
	CreateMedication(record model.MedicationRecord) model.MedicationRecord
	LatestMedicationOn(day time.Time) *model.MedicationRecord
	CreateINR(record model.INRRecord) model.INRRecord
	ListINR() []model.INRRecord
	LatestINR() *model.INRRecord
	GetSettings() model.UserSettings
	UpdateSettings(settings model.UserSettings) model.UserSettings
}
