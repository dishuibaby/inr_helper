import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../state/app_providers.dart';
import 'widgets/reminder_banner.dart';
import 'widgets/summary_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(homeSummaryProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('抗凝小助手', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('记录服药与 INR 趋势，不替代医生决策。', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          summary.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (error, _) => Text('加载失败：$error'),
            data: (data) => Column(
              children: [
                ReminderBanner(reminder: data.prominentReminder),
                SummaryCard(
                  title: '今日计划剂量',
                  value: '${data.todayMedication.plannedDoseTablets.toStringAsFixed(1)} 片',
                  subtitle: '状态：${data.todayMedication.status.name}',
                  icon: Icons.medication,
                ),
                SummaryCard(
                  title: '最近 INR',
                  value: data.latestInr == null ? '暂无记录' : data.latestInr!.correctedValue.toStringAsFixed(2),
                  subtitle: data.latestInr == null ? null : '原始值 ${data.latestInr!.rawValue.toStringAsFixed(2)} · ${data.latestInr!.abnormalTier.name}',
                  icon: Icons.monitor_heart,
                ),
                SummaryCard(
                  title: '下次检测',
                  value: DateFormat('M月d日 HH:mm').format(data.nextTestAt.toLocal()),
                  subtitle: '按设置的检测周期估算',
                  icon: Icons.event_available,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
