import type { InrRecord, InrRecordsResponse, InrTargetRange, InrTrendPoint } from '../../types/api';
import { classifyInr, inrTierPrompt } from '../../utils/inr';
import { request } from '../../utils/request';

interface TrendRow {
  date: string;
  rawDisplay: string;
  correctedDisplay: string;
  deltaDisplay: string;
}

type InrRecordView = InrRecord & {
  rawDisplay: string;
  correctedDisplay: string;
};

interface InrPageData {
  loading: boolean;
  errorText: string;
  trendRows: TrendRow[];
  latestPrompt: string;
  records: InrRecordView[];
  targetText: string;
  emptyText: string;
}

interface InrPageThis {
  setData(data: Partial<InrPageData>): void;
  loadInrRecords(): Promise<void>;
  applyResponse(response: InrRecordsResponse, errorText?: string): void;
}

const targetRange: InrTargetRange = { min: 1.8, max: 2.5 };
const fallbackTrend: InrTrendPoint[] = [
  { date: '04-03', rawValue: 2.1, correctedValue: 2.16 },
  { date: '04-10', rawValue: 2.4, correctedValue: 2.46 },
  { date: '04-17', rawValue: 2.58, correctedValue: 2.64 },
  { date: '04-24', rawValue: 2.36, correctedValue: 2.42 }
];

function makeFallbackRecords(): InrRecord[] {
  return fallbackTrend.map((point, index) => ({
    id: `demo-${index}`,
    testedAt: point.date,
    rawValue: point.rawValue,
    correctedValue: point.correctedValue,
    trend: point.correctedValue < targetRange.min ? 'low' : point.correctedValue > targetRange.max ? 'high' : 'in_range',
    abnormalTier: classifyInr(point.correctedValue, targetRange),
    testMethod: index % 2 === 0 ? 'hospital_lab' : 'poct_device'
  }));
}

function formatTrendRows(trend: InrTrendPoint[]): TrendRow[] {
  return trend.map((point) => {
    const delta = point.correctedValue - point.rawValue;
    const sign = delta >= 0 ? '+' : '';

    return {
      date: point.date,
      rawDisplay: point.rawValue.toFixed(2),
      correctedDisplay: point.correctedValue.toFixed(2),
      deltaDisplay: `${sign}${delta.toFixed(2)}`
    };
  });
}

function formatRecordViews(records: InrRecord[]): InrRecordView[] {
  return records.map((record) => ({
    ...record,
    rawDisplay: record.rawValue.toFixed(2),
    correctedDisplay: record.correctedValue.toFixed(2)
  }));
}

Page({
  data: {
    loading: true,
    errorText: '',
    trendRows: [],
    latestPrompt: '暂无 INR 记录',
    records: [],
    targetText: '目标范围 1.8 - 2.5',
    emptyText: '暂无趋势数据'
  } as InrPageData,

  onLoad(this: InrPageThis) {
    this.loadInrRecords();
  },

  async loadInrRecords(this: InrPageThis) {
    this.setData({ loading: true, errorText: '' });

    try {
      const response = await request<InrRecordsResponse>('/inr/records');
      this.applyResponse(response);
    } catch (_error) {
      this.applyResponse(
        {
          records: makeFallbackRecords(),
          trend: fallbackTrend,
          targetRange
        },
        '暂时无法连接服务端，已展示本地示例数据。'
      );
    }
  },

  applyResponse(this: InrPageThis, response: InrRecordsResponse, errorText = '') {
    const latest = response.records[0] ?? null;
    this.setData({
      loading: false,
      errorText,
      trendRows: formatTrendRows(response.trend),
      latestPrompt: latest ? inrTierPrompt(latest.abnormalTier) : '暂无 INR 记录',
      records: formatRecordViews(response.records),
      targetText: `目标范围 ${response.targetRange.min.toFixed(1)} - ${response.targetRange.max.toFixed(1)}`,
      emptyText: response.trend.length === 0 ? '暂无趋势数据，请记录 INR 后查看原始/校正对比。' : ''
    });
  }
});
