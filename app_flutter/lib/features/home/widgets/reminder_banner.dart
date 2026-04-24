import 'package:flutter/material.dart';

import '../../../domain/models/reminder.dart';

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({required this.reminder, super.key});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (reminder.level) {
      ReminderLevel.strong => (Theme.of(context).colorScheme.error, Icons.priority_high),
      ReminderLevel.weak => (Colors.orange, Icons.info_outline),
      ReminderLevel.normal => (Theme.of(context).colorScheme.primary, Icons.check_circle_outline),
    };

    return Card(
      color: color.withOpacity(0.10),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(reminder.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
