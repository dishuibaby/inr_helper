import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/medication.dart';
import '../../state/app_providers.dart';
import 'widgets/dose_mode_selector.dart';

class MedicationPage extends ConsumerStatefulWidget {
  const MedicationPage({super.key});

  @override
  ConsumerState<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends ConsumerState<MedicationPage> {
  final _doseController = TextEditingController(text: '1.5');
  final _tomorrowDoseController = TextEditingController(text: '1.5');
  MedicationActionType _actionType = MedicationActionType.taken;
  TomorrowDoseMode _tomorrowDoseMode = TomorrowDoseMode.planned;

  @override
  void dispose() {
    _doseController.dispose();
    _tomorrowDoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(medicationActionsProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('服药记录', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<MedicationActionType>(
                  segments: const [
                    ButtonSegment(value: MedicationActionType.taken, label: Text('已服'), icon: Icon(Icons.check)),
                    ButtonSegment(value: MedicationActionType.paused, label: Text('暂停'), icon: Icon(Icons.pause)),
                    ButtonSegment(value: MedicationActionType.missed, label: Text('漏服'), icon: Icon(Icons.close)),
                  ],
                  selected: {_actionType},
                  onSelectionChanged: (selected) => setState(() => _actionType = selected.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _doseController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '实际剂量（片）'),
                ),
                const SizedBox(height: 16),
                DoseModeSelector(value: _tomorrowDoseMode, onChanged: (value) => setState(() => _tomorrowDoseMode = value)),
                if (_tomorrowDoseMode == TomorrowDoseMode.manual) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tomorrowDoseController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: '明日剂量（片）'),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: actionState.isLoading ? null : _submit,
                  icon: actionState.isLoading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                  label: const Text('记录当前服药动作'),
                ),
                actionState.when(
                  data: (record) => record == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 12), child: Text('已记录：${record.actionType.name}')),
                  loading: () => const SizedBox.shrink(),
                  error: (error, _) => Padding(padding: const EdgeInsets.only(top: 12), child: Text('提交失败：$error')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final request = CreateMedicationRecordRequest(
      actionType: _actionType,
      actualDoseTablets: double.tryParse(_doseController.text) ?? 0,
      tomorrowDoseMode: _tomorrowDoseMode,
      tomorrowDoseTablets: _tomorrowDoseMode == TomorrowDoseMode.manual ? double.tryParse(_tomorrowDoseController.text) : null,
    );
    ref.read(medicationActionsProvider.notifier).record(request);
  }
}
