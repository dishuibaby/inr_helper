export type InrTestMethod = 'hospital_lab' | 'poct_device' | 'home_device' | 'other';
export type TestCycleUnit = 'day' | 'week' | 'month';
export type TomorrowDoseMode = 'planned' | 'manual';
export type MedicationActionType = 'taken' | 'paused' | 'missed';
export type InrTier = 'normal' | 'weak_low' | 'weak_high' | 'strong_low' | 'strong_high';
export type InrTrend = 'low' | 'in_range' | 'high';

export interface ApiEnvelope<T> {
  code: number;
  message: string;
  data: T;
}

export interface InrTargetRange {
  min: number;
  max: number;
}

export interface Reminder {
  level: 'normal' | 'weak' | 'strong';
  title: string;
  body: string;
}

export interface TodayMedication {
  status: 'pending' | MedicationActionType;
  plannedDoseTablets: number;
}

export interface InrRecord {
  id: string;
  testedAt: string;
  rawValue: number;
  correctedValue: number;
  trend: InrTrend;
  abnormalTier: InrTier;
  testMethod: InrTestMethod;
}

export interface InrTrendPoint {
  date: string;
  rawValue: number;
  correctedValue: number;
}

export interface HomeSummary {
  prominentReminder: Reminder;
  latestInr: InrRecord | null;
  nextTestAt: string;
  todayMedication: TodayMedication;
}

export interface MedicationActionRequest {
  actionType: MedicationActionType;
  actualDoseTablets: number;
  tomorrowDoseMode: TomorrowDoseMode;
  tomorrowDoseTablets?: number;
}

export interface MedicationRecord {
  id: string;
  actionType: MedicationActionType;
  actualDoseTablets: number;
  recordedAt: string;
  tomorrowDoseMode: TomorrowDoseMode;
  tomorrowDoseTablets?: number;
}

export interface Settings {
  targetInrMin: number;
  targetInrMax: number;
  defaultMedicationTime: string;
  testCycle: {
    unit: TestCycleUnit;
    interval: number;
  };
  testMethods: InrTestMethod[];
  inrOffset: number;
}

export interface InrRecordsResponse {
  records: InrRecord[];
  trend: InrTrendPoint[];
  targetRange: InrTargetRange;
}
