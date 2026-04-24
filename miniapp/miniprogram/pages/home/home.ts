import type { HomeSummary } from '../../types/api';
import { inrTierPrompt } from '../../utils/inr';
import { request } from '../../utils/request';

type HomeViewModel = HomeSummary & {
  latestCorrectedDisplay: string;
  latestRawDisplay: string;
  inrPrompt: string;
  reminderTitle: string;
  reminderSubtitle: string;
  completionText: string;
};

interface HomePageData {
  loading: boolean;
  errorText: string;
  summary: HomeViewModel;
}

interface HomePageThis {
  setData(data: Partial<HomePageData>): void;
  loadSummary(): Promise<void>;
  applySummary(summary: HomeSummary, errorText?: string): void;
}

const emptySummary: HomeViewModel = {
  prominentReminder: {
    level: 'strong',
    title: '今日必须确认',
    body: '请按医嘱完成今日抗凝药记录。'
  },
  latestInr: null,
  nextTestAt: '待设置',
  todayMedication: { status: 'pending', plannedDoseTablets: 0 },
  latestCorrectedDisplay: '--',
  latestRawDisplay: '原始 INR --',
  inrPrompt: '暂无 INR 记录，请按计划检测后记录。',
  reminderTitle: '今日必须确认',
  reminderSubtitle: '完成服药后只记录事实与时间，不生成剂量建议。',
  completionText: '待完成记录'
};

const fallbackSummary: HomeSummary = {
  prominentReminder: {
    level: 'strong',
    title: '今晚服药后必须确认',
    body: '请立即点击“完成今日服药”留下操作时间。'
  },
  latestInr: {
    id: 'demo-inr-1',
    testedAt: '2026-04-24T08:30:00+08:00',
    rawValue: 2.36,
    correctedValue: 2.42,
    trend: 'in_range',
    abnormalTier: 'normal',
    testMethod: 'hospital_lab'
  },
  nextTestAt: '2026-05-01T08:30:00+08:00',
  todayMedication: { status: 'pending', plannedDoseTablets: 1.25 }
};

function buildReminderSubtitle(summary: HomeSummary): string {
  if (summary.todayMedication.status !== 'pending') {
    return '今日已记录。请继续按医生确认的计划执行。';
  }

  return summary.prominentReminder.body || '请按医生确认的方案执行；本应用仅做记录与提醒。';
}

Page({
  data: {
    loading: true,
    errorText: '',
    summary: emptySummary
  } as HomePageData,

  onLoad(this: HomePageThis) {
    this.loadSummary();
  },

  async loadSummary(this: HomePageThis) {
    this.setData({ loading: true, errorText: '' });

    try {
      const summary = await request<HomeSummary>('/home/summary');
      this.applySummary(summary);
    } catch (_error) {
      this.applySummary(fallbackSummary, '暂时无法连接服务端，已展示本地示例数据。');
    }
  },

  applySummary(this: HomePageThis, summary: HomeSummary, errorText = '') {
    const latestInr = summary.latestInr;
    const completed = summary.todayMedication.status !== 'pending';
    const viewModel: HomeViewModel = {
      ...summary,
      latestCorrectedDisplay: latestInr ? latestInr.correctedValue.toFixed(2) : '--',
      latestRawDisplay: latestInr ? `原始 INR ${latestInr.rawValue.toFixed(2)}` : '原始 INR --',
      inrPrompt: latestInr ? inrTierPrompt(latestInr.abnormalTier) : emptySummary.inrPrompt,
      reminderTitle: completed ? '今日记录已完成' : summary.prominentReminder.title,
      reminderSubtitle: buildReminderSubtitle(summary),
      completionText: completed ? '已完成记录' : '待完成记录'
    };

    this.setData({
      loading: false,
      errorText,
      summary: viewModel
    });
  }
});
