import 'package:flutter/material.dart';

import '../../../domain/models/medication.dart';

class DoseModeSelector extends StatelessWidget {
  const DoseModeSelector({required this.value, required this.onChanged, super.key});

  final TomorrowDoseMode value;
  final ValueChanged<TomorrowDoseMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TomorrowDoseMode>(
      segments: const [
        ButtonSegment(value: TomorrowDoseMode.planned, label: Text('沿用计划'), icon: Icon(Icons.event_repeat)),
        ButtonSegment(value: TomorrowDoseMode.manual, label: Text('手动设置'), icon: Icon(Icons.edit_calendar)),
      ],
      selected: {value},
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}
