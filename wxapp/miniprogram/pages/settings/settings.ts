import type { InrTargetRange, InrTestMethod, Settings, TestCycleUnit } from '../../types/api';
import { request } from '../../utils/request';

interface PickerOption<T extends string> {
  label: string;
  value: T;
}

interface SettingsPageData {
  loading: boolean;
  saving: boolean;
  errorText: string;
  settings: Settings;
  methodOptions: PickerOption<InrTestMethod>[];
  cycleOptions: PickerOption<TestCycleUnit>[];
  methodIndex: number;
  cycleIndex: number;
  offsetInput: string;
  cycleValueInput: string;
  targetMinInput: string;
  targetMaxInput: string;
}

interface SettingsPageThis {
  data: SettingsPageData;
  setData(data: Partial<SettingsPageData>): void;
  loadSettings(): Promise<void>;
  applySettings(settings: Settings, errorText?: string): void;
  saveSettings(settings: Settings): Promise<void>;
}

const methodOptions: PickerOption<InrTestMethod>[] = [
  { label: '医院实验室', value: 'hospital_lab' },
  { label: 'POCT 指尖设备', value: 'poct_device' },
  { label: '家用检测仪', value: 'home_device' },
  { label: '其他方式', value: 'other' }
];

const cycleOptions: PickerOption<TestCycleUnit>[] = [
  { label: '天', value: 'day' },
  { label: '周', value: 'week' },
  { label: '月', value: 'month' }
];

const defaultSettings: Settings = {
  targetInrMin: 1.8,
  targetInrMax: 2.5,
  defaultMedicationTime: '08:00',
  testCycle: { interval: 1, unit: 'week' },
  testMethods: ['hospital_lab', 'poct_device', 'home_device'],
  inrOffset: 0
};

function parseBoundedNumber(value: string, min: number, max: number): number | null {
  const parsed = Number(value.trim());
  if (!Number.isFinite(parsed) || parsed < min || parsed > max) {
    return null;
  }

  return Math.round(parsed * 100) / 100;
}

function parseTargetRange(minInput: string, maxInput: string): InrTargetRange | null {
  const min = parseBoundedNumber(minInput, 0.8, 6);
  const max = parseBoundedNumber(maxInput, 0.8, 6);

  if (min === null || max === null || min >= max) {
    return null;
  }

  return { min, max };
}

function selectedMethod(settings: Settings): InrTestMethod {
  return settings.testMethods[0] ?? defaultSettings.testMethods[0];
}

Page({
  data: {
    loading: true,
    saving: false,
    errorText: '',
    settings: defaultSettings,
    methodOptions,
    cycleOptions,
    methodIndex: 0,
    cycleIndex: 1,
    offsetInput: '0',
    cycleValueInput: '1',
    targetMinInput: '1.8',
    targetMaxInput: '2.5'
  } as SettingsPageData,

  onLoad(this: SettingsPageThis) {
    this.loadSettings();
  },

  async loadSettings(this: SettingsPageThis) {
    this.setData({ loading: true, errorText: '' });

    try {
      const settings = await request<Settings>('/settings');
      this.applySettings(settings);
    } catch (_error) {
      this.applySettings(defaultSettings, '暂时无法连接服务端，已展示默认设置。');
    }
  },

  onMethodChange(this: SettingsPageThis, event: { detail: { value: string } }) {
    const methodIndex = Number(event.detail.value);
    const method = this.data.methodOptions[methodIndex]?.value ?? selectedMethod(defaultSettings);
    this.applySettings({ ...this.data.settings, testMethods: [method] });
  },

  onCycleUnitChange(this: SettingsPageThis, event: { detail: { value: string } }) {
    const cycleIndex = Number(event.detail.value);
    const unit = this.data.cycleOptions[cycleIndex]?.value ?? defaultSettings.testCycle.unit;
    this.applySettings({
      ...this.data.settings,
      testCycle: { ...this.data.settings.testCycle, unit }
    });
  },

  onOffsetInput(this: SettingsPageThis, event: { detail: { value: string } }) {
    this.setData({ offsetInput: event.detail.value, errorText: '' });
  },

  onCycleValueInput(this: SettingsPageThis, event: { detail: { value: string } }) {
    this.setData({ cycleValueInput: event.detail.value, errorText: '' });
  },

  onTargetMinInput(this: SettingsPageThis, event: { detail: { value: string } }) {
    this.setData({ targetMinInput: event.detail.value, errorText: '' });
  },

  onTargetMaxInput(this: SettingsPageThis, event: { detail: { value: string } }) {
    this.setData({ targetMaxInput: event.detail.value, errorText: '' });
  },

  onSave(this: SettingsPageThis) {
    const inrOffset = parseBoundedNumber(this.data.offsetInput, -1, 1);
    const cycleValue = parseBoundedNumber(this.data.cycleValueInput, 1, 365);
    const targetRange = parseTargetRange(this.data.targetMinInput, this.data.targetMaxInput);

    if (inrOffset === null) {
      this.setData({ errorText: 'INR 校正偏移需在 -1.00 到 1.00 之间。' });
      wx.showToast({ title: '请检查校正偏移', icon: 'none' });
      return;
    }

    if (cycleValue === null) {
      this.setData({ errorText: '检测周期需在 1 到 365 之间。' });
      wx.showToast({ title: '请检查检测周期', icon: 'none' });
      return;
    }

    if (targetRange === null) {
      this.setData({ errorText: '目标范围需在 0.8 到 6.0 之间，且下限小于上限。' });
      wx.showToast({ title: '请检查目标范围', icon: 'none' });
      return;
    }

    const settings: Settings = {
      ...this.data.settings,
      inrOffset,
      testCycle: {
        ...this.data.settings.testCycle,
        interval: cycleValue
      },
      targetInrMin: targetRange.min,
      targetInrMax: targetRange.max
    };

    void this.saveSettings(settings);
  },

  applySettings(this: SettingsPageThis, settings: Settings, errorText = '') {
    const methodIndex = methodOptions.findIndex((option) => option.value === selectedMethod(settings));
    const cycleIndex = cycleOptions.findIndex((option) => option.value === settings.testCycle.unit);

    this.setData({
      loading: false,
      errorText,
      settings,
      methodIndex: Math.max(methodIndex, 0),
      cycleIndex: Math.max(cycleIndex, 0),
      offsetInput: String(settings.inrOffset),
      cycleValueInput: String(settings.testCycle.interval),
      targetMinInput: String(settings.targetInrMin),
      targetMaxInput: String(settings.targetInrMax)
    });
  },

  async saveSettings(this: SettingsPageThis, settings: Settings) {
    this.setData({ saving: true, errorText: '' });

    try {
      const saved = await request<Settings>('/settings', {
        method: 'PUT',
        data: settings
      });
      this.applySettings(saved);
    } catch (_error) {
      this.applySettings(settings, '暂时无法连接服务端，已先保存在本页展示。');
    }

    this.setData({ saving: false });
    wx.showToast({ title: '已保存', icon: 'success' });
  }
});
