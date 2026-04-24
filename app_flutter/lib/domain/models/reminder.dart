enum ReminderLevel { normal, weak, strong }

ReminderLevel reminderLevelFromJson(String value) {
  return ReminderLevel.values.firstWhere(
    (level) => level.name == value,
    orElse: () => ReminderLevel.normal,
  );
}

class Reminder {
  const Reminder({required this.level, required this.title, required this.body});

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      level: reminderLevelFromJson(json['level'] as String? ?? 'normal'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  final ReminderLevel level;
  final String title;
  final String body;
}
