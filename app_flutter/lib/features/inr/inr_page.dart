import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/inr.dart';
import '../../state/app_providers.dart';
import 'widgets/inr_trend_card.dart';

class InrPage extends ConsumerStatefulWidget {
  const InrPage({super.key});

  @override
  ConsumerState<InrPage> createState() => _InrPageState();
}

class _InrPageState extends ConsumerState<InrPage> {
  final _rawController = TextEditingController(text: '2.2');
  final _offsetController = TextEditingController(text: '0');
  TestMethod _testMethod = TestMethod.hospitalLab;

  @override
  void dispose() {
    _rawController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(inrRecordsProvider);
    final actionState = ref.watch(inrActionsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(inrRecordsProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('INR 监测', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          records.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (error, _) => Text('加载失败：$error'),
            data: (items) => Column(
              children: [
                InrTrendCard(records: items),
                ...items.map((record) => Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(record.correctedValue.toStringAsFixed(1))),
                        title: Text('校正后 ${record.correctedValue.toStringAsFixed(2)} · 原始 ${record.rawValue.toStringAsFixed(2)}'),
                        subtitle: Text('${record.testMethod.name} · ${DateFormat('yyyy-MM-dd HH:mm').format(record.testedAt.toLocal())}'),
                        trailing: Text(record.abnormalTier.name),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('新增 INR', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(controller: _rawController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: '原始 INR')),
                  const SizedBox(height: 12),
                  TextField(controller: _offsetController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: '校正偏移')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TestMethod>(
                    value: _testMethod,
                    decoration: const InputDecoration(labelText: '检测方式'),
                    items: TestMethod.values.map((method) => DropdownMenuItem(value: method, child: Text(method.name))).toList(),
                    onChanged: (value) => setState(() => _testMethod = value ?? TestMethod.hospitalLab),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: actionState.isLoading ? null : _submit,
                    icon: const Icon(Icons.add_chart),
                    label: const Text('保存 INR 记录'),
                  ),
                  actionState.when(
                    data: (record) => record == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 12), child: Text('已保存：${record.correctedValue.toStringAsFixed(2)}')),
                    loading: () => const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
                    error: (error, _) => Padding(padding: const EdgeInsets.only(top: 12), child: Text('提交失败：$error')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final request = CreateInrRecordRequest(
      rawValue: double.tryParse(_rawController.text) ?? 0,
      offset: double.tryParse(_offsetController.text),
      testMethod: _testMethod,
      testedAt: DateTime.now(),
    );
    ref.read(inrActionsProvider.notifier).record(request);
  }
}
