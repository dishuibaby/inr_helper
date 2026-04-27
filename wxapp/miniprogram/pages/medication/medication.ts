import type { MedicationActionRequest, MedicationRecord, TomorrowDoseMode } from '../../types/api';
import { request } from '../../utils/request';

interface TomorrowDoseSelection {
  mode: TomorrowDoseMode;
  manualDoseTablets?: number;
}

interface DoseOption {
  label: string;
  value: TomorrowDoseMode;
}

interface MedicationPageData {
  completedToday: boolean;
  submitting: boolean;
  errorText: string;
  lastOperationTime: string;
  tomorrowDoseText: string;
  doseOptions: DoseOption[];
  doseModeIndex: number;
  manualDoseInput: string;
}

interface MedicationPageThis {
  data: MedicationPageData;
  setData(data: Partial<MedicationPageData>): void;
  submitCompletion(selection: TomorrowDoseSelection): Promise<void>;
}

const doseOptions: DoseOption[] = [
  { label: '按既定计划', value: 'planned' },
  { label: '手动记录剂量', value: 'manual' }
];

function formatDoseSelection(selection: TomorrowDoseSelection): string {
  if (selection.mode === 'planned') {
    return '明日剂量：按医生已确认的既定计划';
  }

  return `明日剂量：手动记录 ${selection.manualDoseTablets?.toFixed(2) ?? '--'} 片`;
}

function selectionFromRecord(record: MedicationRecord): TomorrowDoseSelection {
  return { mode: record.tomorrowDoseMode, manualDoseTablets: record.tomorrowDoseTablets };
}

function nowDisplay(): string {
  return new Date().toLocaleString('zh-CN', { hour12: false });
}

function parseManualDose(value: string): number | null {
  const dose = Number(value.trim());
  if (!Number.isFinite(dose) || dose <= 0 || dose > 10) {
    return null;
  }

  return Math.round(dose * 100) / 100;
}

Page({
  data: {
    completedToday: false,
    submitting: false,
    errorText: '',
    lastOperationTime: '尚未记录',
    tomorrowDoseText: '完成服药后选择明日剂量记录模式',
    doseOptions,
    doseModeIndex: 0,
    manualDoseInput: ''
  } as MedicationPageData,

  onDoseModeChange(this: MedicationPageThis, event: { detail: { value: string } }) {
    const doseModeIndex = Number(event.detail.value);
    this.setData({ doseModeIndex, errorText: '' });
  },

  onManualDoseInput(this: MedicationPageThis, event: { detail: { value: string } }) {
    this.setData({ manualDoseInput: event.detail.value, errorText: '' });
  },

  onCompleteMedication(this: MedicationPageThis) {
    const selectedMode = this.data.doseOptions[this.data.doseModeIndex]?.value ?? 'planned';
    const selection: TomorrowDoseSelection = { mode: selectedMode };

    if (selectedMode === 'manual') {
      const manualDoseTablets = parseManualDose(this.data.manualDoseInput);
      if (manualDoseTablets === null) {
        this.setData({ errorText: '请输入医生已确认的明日剂量（片数，0-10）。' });
        wx.showToast({ title: '请输入有效剂量', icon: 'none' });
        return;
      }
      selection.manualDoseTablets = manualDoseTablets;
    }

    wx.showModal({
      title: '确认完成今日服药',
      content: '系统将记录完成时间和明日剂量记录模式；不会提供补服或剂量建议。',
      confirmText: '确认记录',
      cancelText: '再检查',
      success: (result) => {
        if (result.confirm) {
          void this.submitCompletion(selection);
        }
      }
    });
  },

  async submitCompletion(this: MedicationPageThis, selection: TomorrowDoseSelection) {
    const payload: MedicationActionRequest = {
      actionType: 'taken',
      actualDoseTablets: 0,
      tomorrowDoseMode: selection.mode,
      tomorrowDoseTablets: selection.manualDoseTablets
    };

    this.setData({ submitting: true, errorText: '' });

    try {
      const record = await request<MedicationRecord>('/medication/records', {
        method: 'POST',
        data: payload
      });
      this.setData({
        completedToday: true,
        submitting: false,
        lastOperationTime: record.recordedAt,
        tomorrowDoseText: formatDoseSelection(selectionFromRecord(record))
      });
    } catch (_error) {
      this.setData({
        completedToday: true,
        submitting: false,
        errorText: '暂时无法连接服务端，已先保存在本页展示。',
        lastOperationTime: nowDisplay(),
        tomorrowDoseText: formatDoseSelection(selection)
      });
    }

    wx.showToast({ title: '已记录完成', icon: 'success' });
  }
});
