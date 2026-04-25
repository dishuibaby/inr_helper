package model

import "time"

type Envelope struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

type Reminder struct {
	Level string `json:"level"`
	Title string `json:"title"`
	Body  string `json:"body"`
}

type TodayMedication struct {
	Status             string  `json:"status"`
	PlannedDoseTablets float64 `json:"plannedDoseTablets"`
}

type LatestINRDisplayText struct {
	Label       string `json:"label"`
	TargetLabel string `json:"targetLabel"`
	RawLabel    string `json:"rawLabel"`
}

type NextTestDisplayText struct {
	Label     string `json:"label"`
	CycleText string `json:"cycleText"`
}

type TodayMedicationDisplayText struct {
	Title             string `json:"title"`
	PrimaryAction     string `json:"primaryAction"`
	PauseAction       string `json:"pauseAction"`
	MissAction        string `json:"missAction"`
	YesterdayDoseText string `json:"yesterdayDoseText"`
	StatusText        string `json:"statusText"`
	TomorrowDoseTitle string `json:"tomorrowDoseTitle"`
	PlannedDoseLabel  string `json:"plannedDoseLabel"`
	ManualDoseLabel   string `json:"manualDoseLabel"`
	RecordedAtHint    string `json:"recordedAtHint"`
	ConfirmAction     string `json:"confirmAction"`
}

type HomeSummaryDisplayText struct {
	Locale          string                     `json:"locale"`
	LatestINR       LatestINRDisplayText       `json:"latestInr"`
	NextTest        NextTestDisplayText        `json:"nextTest"`
	TodayMedication TodayMedicationDisplayText `json:"todayMedication"`
}

type HomeSummary struct {
	ProminentReminder Reminder               `json:"prominentReminder"`
	LatestINR         *INRRecord             `json:"latestInr"`
	NextTestAt        time.Time              `json:"nextTestAt"`
	TodayMedication   TodayMedication        `json:"todayMedication"`
	DisplayText       HomeSummaryDisplayText `json:"displayText"`
}

type MedicationRecord struct {
	ID                  string    `json:"id"`
	ActionType          string    `json:"actionType"`
	ActualDoseTablets   float64   `json:"actualDoseTablets"`
	RecordedAt          time.Time `json:"recordedAt"`
	TomorrowDoseMode    string    `json:"tomorrowDoseMode"`
	TomorrowDoseTablets *float64  `json:"tomorrowDoseTablets,omitempty"`
}

type CreateMedicationRecordRequest struct {
	ActionType          string   `json:"actionType" binding:"required,oneof=taken paused missed"`
	ActualDoseTablets   float64  `json:"actualDoseTablets"`
	TomorrowDoseMode    string   `json:"tomorrowDoseMode" binding:"required,oneof=planned manual"`
	TomorrowDoseTablets *float64 `json:"tomorrowDoseTablets"`
}

type INRRecordDisplayText struct {
	StatusLabel string `json:"statusLabel"`
	Note        string `json:"note"`
	RawLabel    string `json:"rawLabel"`
	MethodLabel string `json:"methodLabel"`
}

type INRRecord struct {
	ID             string               `json:"id"`
	RawValue       float64              `json:"rawValue"`
	OffsetValue    float64              `json:"offsetValue"`
	CorrectedValue float64              `json:"correctedValue"`
	Trend          string               `json:"trend"`
	AbnormalTier   string               `json:"abnormalTier"`
	TestMethod     string               `json:"testMethod"`
	TestedAt       time.Time            `json:"testedAt"`
	DisplayText    INRRecordDisplayText `json:"displayText"`
}

type INRTrendPoint struct {
	Date           string  `json:"date"`
	RawValue       float64 `json:"rawValue"`
	CorrectedValue float64 `json:"correctedValue"`
}

type INRTrendDisplayText struct {
	Title                string `json:"title"`
	Subtitle             string `json:"subtitle"`
	CorrectedSeriesLabel string `json:"correctedSeriesLabel"`
	RawSeriesLabel       string `json:"rawSeriesLabel"`
	StrongLabel          string `json:"strongLabel"`
	WeakLabel            string `json:"weakLabel"`
}

type INRRecordLabelsDisplayText struct {
	Normal     string `json:"normal"`
	WeakLow    string `json:"weakLow"`
	StrongLow  string `json:"strongLow"`
	WeakHigh   string `json:"weakHigh"`
	StrongHigh string `json:"strongHigh"`
}

type INRRecordsDisplayText struct {
	Locale       string                     `json:"locale"`
	Trend        INRTrendDisplayText        `json:"trend"`
	RecordLabels INRRecordLabelsDisplayText `json:"recordLabels"`
	RecordsTitle string                     `json:"recordsTitle"`
	RecordsHint  string                     `json:"recordsHint"`
}

type INRRecordsResponse struct {
	Records     []INRRecord           `json:"records"`
	Trend       []INRTrendPoint       `json:"trend"`
	TargetRange TargetRange           `json:"targetRange"`
	DisplayText INRRecordsDisplayText `json:"displayText"`
}

type TargetRange struct {
	Min float64 `json:"min"`
	Max float64 `json:"max"`
}

type CreateINRRecordRequest struct {
	RawValue   float64  `json:"rawValue" binding:"required,gt=0"`
	Offset     *float64 `json:"offset"`
	TestMethod string   `json:"testMethod" binding:"required,oneof=hospital_lab poct_device home_device other"`
	TestedAt   string   `json:"testedAt" binding:"required"`
}

type TestCycle struct {
	Unit     string `json:"unit" binding:"required,oneof=day week month"`
	Interval int    `json:"interval" binding:"required,min=1"`
}

type SettingsDisplayText struct {
	Locale              string `json:"locale"`
	INRRangeTitle       string `json:"inrRangeTitle"`
	INRRangeHint        string `json:"inrRangeHint"`
	TestMethodTitle     string `json:"testMethodTitle"`
	TestMethodHint      string `json:"testMethodHint"`
	OffsetTitle         string `json:"offsetTitle"`
	OffsetHint          string `json:"offsetHint"`
	CycleTitle          string `json:"cycleTitle"`
	CycleHint           string `json:"cycleHint"`
	MedicationTimeTitle string `json:"medicationTimeTitle"`
	SaveAction          string `json:"saveAction"`
}

type UserSettings struct {
	TargetINRMin          float64             `json:"targetInrMin"`
	TargetINRMax          float64             `json:"targetInrMax"`
	DefaultMedicationTime string              `json:"defaultMedicationTime"`
	TestCycle             TestCycle           `json:"testCycle" binding:"required"`
	TestMethods           []string            `json:"testMethods" binding:"required,min=1,dive,oneof=hospital_lab poct_device home_device other"`
	INROffset             float64             `json:"inrOffset"`
	DisplayText           SettingsDisplayText `json:"displayText"`
}
