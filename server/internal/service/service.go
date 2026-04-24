package service

import (
	"errors"
	"time"

	"warfarin-inr-demo/server/internal/model"
	"warfarin-inr-demo/server/internal/repository"
)

type Service struct {
	repo repository.Repository
	now  func() time.Time
}

func New(repo repository.Repository) *Service {
	return &Service{repo: repo, now: time.Now}
}

func (s *Service) HomeSummary() model.HomeSummary {
	settings := s.repo.GetSettings()
	latestINR := s.repo.LatestINR()
	today := s.now()
	nextTestAt := nextTestTime(today, settings.TestCycle)
	reminder := model.Reminder{Level: "strong", Title: "今日服药待确认", Body: "请按医嘱完成服药记录，本应用不提供剂量调整建议。"}
	todayMedication := model.TodayMedication{Status: "pending", PlannedDoseTablets: 0}

	if medication := s.repo.LatestMedicationOn(today); medication != nil {
		todayMedication.Status = medication.ActionType
		todayMedication.PlannedDoseTablets = medication.ActualDoseTablets
		reminder = model.Reminder{Level: "normal", Title: "今日记录已完成", Body: "已记录今日服药状态。"}
	}

	if latestINR != nil && latestINR.AbnormalTier != "normal" {
		reminder = model.Reminder{Level: "strong", Title: "INR 结果需关注", Body: "请联系医生确认后续处理，本应用不提供剂量调整建议。"}
	}

	return model.HomeSummary{ProminentReminder: reminder, LatestINR: latestINR, NextTestAt: nextTestAt, TodayMedication: todayMedication}
}

func (s *Service) CreateMedication(req model.CreateMedicationRecordRequest) (model.MedicationRecord, error) {
	clientTime, err := parseOptionalTime(req.ClientTime)
	if err != nil {
		return model.MedicationRecord{}, err
	}
	record := model.MedicationRecord{
		ActionType:          req.ActionType,
		ActualDoseTablets:   req.ActualDoseTablets,
		ClientTime:          clientTime,
		RecordedAt:          s.now(),
		TomorrowDoseMode:    req.TomorrowDoseMode,
		TomorrowDoseTablets: req.TomorrowDoseTablets,
	}
	return s.repo.CreateMedication(record), nil
}

func (s *Service) ListINR() []model.INRRecord {
	return s.repo.ListINR()
}

func (s *Service) CreateINR(req model.CreateINRRecordRequest) (model.INRRecord, error) {
	testedAt, err := parseRequiredTime(req.TestedAt)
	if err != nil {
		return model.INRRecord{}, err
	}
	settings := s.repo.GetSettings()
	offset := settings.INROffset
	if req.Offset != nil {
		offset = *req.Offset
	}
	correctedValue := req.RawValue + offset
	record := model.INRRecord{
		RawValue:       req.RawValue,
		CorrectedValue: correctedValue,
		AbnormalTier:   abnormalTier(correctedValue, settings),
		TestMethod:     req.TestMethod,
		TestedAt:       testedAt,
	}
	return s.repo.CreateINR(record), nil
}

func (s *Service) GetSettings() model.UserSettings {
	return s.repo.GetSettings()
}

func (s *Service) UpdateSettings(settings model.UserSettings) (model.UserSettings, error) {
	if settings.TargetINRMin <= 0 || settings.TargetINRMax <= 0 || settings.TargetINRMin >= settings.TargetINRMax {
		return model.UserSettings{}, errors.New("target INR range is invalid")
	}
	return s.repo.UpdateSettings(settings), nil
}

func parseOptionalTime(value string) (time.Time, error) {
	if value == "" {
		return time.Time{}, nil
	}
	return parseRequiredTime(value)
}

func parseRequiredTime(value string) (time.Time, error) {
	parsed, err := time.Parse(time.RFC3339, value)
	if err != nil {
		return time.Time{}, errors.New("time must be RFC3339")
	}
	return parsed, nil
}

func abnormalTier(value float64, settings model.UserSettings) string {
	if value < settings.TargetINRMin-0.1 {
		return "strong_low"
	}
	if value < settings.TargetINRMin {
		return "weak_low"
	}
	if value > settings.TargetINRMax+0.1 {
		return "strong_high"
	}
	if value > settings.TargetINRMax {
		return "weak_high"
	}
	return "normal"
}

func nextTestTime(now time.Time, cycle model.TestCycle) time.Time {
	switch cycle.Unit {
	case "day":
		return now.AddDate(0, 0, cycle.Interval)
	case "month":
		return now.AddDate(0, cycle.Interval, 0)
	default:
		return now.AddDate(0, 0, cycle.Interval*7)
	}
}
