CREATE TABLE IF NOT EXISTS medications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action_type TEXT NOT NULL,
    actual_dose_tablets REAL NOT NULL,
    client_time TEXT,
    recorded_at TEXT NOT NULL,
    tomorrow_dose_mode TEXT NOT NULL,
    tomorrow_dose_tablets REAL
);

CREATE INDEX IF NOT EXISTS idx_medications_recorded_at ON medications(recorded_at);

CREATE TABLE IF NOT EXISTS inr_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    raw_value REAL NOT NULL,
    corrected_value REAL NOT NULL,
    trend TEXT NOT NULL DEFAULT 'in_range',
    abnormal_tier TEXT NOT NULL,
    test_method TEXT NOT NULL,
    tested_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_inr_records_tested_at ON inr_records(tested_at DESC);

CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    target_inr_min REAL NOT NULL,
    target_inr_max REAL NOT NULL,
    default_medication_time TEXT NOT NULL,
    test_cycle_unit TEXT NOT NULL,
    test_cycle_interval INTEGER NOT NULL,
    test_methods TEXT NOT NULL,
    inr_offset REAL NOT NULL
);

INSERT INTO settings (
    id,
    target_inr_min,
    target_inr_max,
    default_medication_time,
    test_cycle_unit,
    test_cycle_interval,
    test_methods,
    inr_offset
)
VALUES (1, 1.8, 2.5, '08:00', 'week', 1, '["hospital_lab","poct_device"]', 0)
ON CONFLICT(id) DO NOTHING;
