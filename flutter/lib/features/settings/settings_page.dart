import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/app_providers.dart';
import 'widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(settingsProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('设置', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          settings.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (error, _) => Text('加载失败：$error'),
            data: (data) => Column(
              children: [
                SettingsTile(title: '目标 INR 范围', value: '${data.targetInrMin} - ${data.targetInrMax}', icon: Icons.track_changes),
                SettingsTile(title: '默认服药时间', value: data.defaultMedicationTime, icon: Icons.schedule),
                SettingsTile(title: '检测周期', value: '每 ${data.testCycle.interval} ${data.testCycle.unit.name}', icon: Icons.event_repeat),
                SettingsTile(title: '检测方式', value: data.testMethods.join('、'), icon: Icons.science_outlined),
                SettingsTile(title: 'INR 校正偏移', value: data.inrOffset.toStringAsFixed(2), icon: Icons.tune),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
