import 'inr.dart';
import 'medication.dart';
import 'reminder.dart';

class HomeSummary {
  const HomeSummary({
    required this.prominentReminder,
    required this.latestInr,
    required this.nextTestAt,
    required this.todayMedication,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      prominentReminder: Reminder.fromJson(json['prominentReminder'] as Map<String, dynamic>? ?? const {}),
      latestInr: json['latestInr'] == null ? null : InrRecord.fromJson(json['latestInr'] as Map<String, dynamic>),
      nextTestAt: DateTime.tryParse(json['nextTestAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      todayMedication: TodayMedication.fromJson(json['todayMedication'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final Reminder prominentReminder;
  final InrRecord? latestInr;
  final DateTime nextTestAt;
  final TodayMedication todayMedication;
}
