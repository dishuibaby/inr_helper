enum TestCycleUnit { day, week, month }

TestCycleUnit _unitFromJson(String? value) {
  return TestCycleUnit.values.firstWhere(
    (unit) => unit.name == value,
    orElse: () => TestCycleUnit.week,
  );
}

class TestCycle {
  const TestCycle({required this.unit, required this.interval});

  factory TestCycle.fromJson(Map<String, dynamic> json) {
    return TestCycle(
      unit: _unitFromJson(json['unit'] as String?),
      interval: json['interval'] as int? ?? 1,
    );
  }

  final TestCycleUnit unit;
  final int interval;

  Map<String, dynamic> toJson() => {'unit': unit.name, 'interval': interval};
}

class UserSettings {
  const UserSettings({
    required this.targetInrMin,
    required this.targetInrMax,
    required this.defaultMedicationTime,
    required this.testCycle,
    required this.testMethods,
    required this.inrOffset,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      targetInrMin: (json['targetInrMin'] as num? ?? 1.8).toDouble(),
      targetInrMax: (json['targetInrMax'] as num? ?? 2.5).toDouble(),
      defaultMedicationTime: json['defaultMedicationTime'] as String? ?? '08:00',
      testCycle: TestCycle.fromJson(json['testCycle'] as Map<String, dynamic>? ?? const {}),
      testMethods: (json['testMethods'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      inrOffset: (json['inrOffset'] as num? ?? 0).toDouble(),
    );
  }

  final double targetInrMin;
  final double targetInrMax;
  final String defaultMedicationTime;
  final TestCycle testCycle;
  final List<String> testMethods;
  final double inrOffset;

  Map<String, dynamic> toJson() => {
        'targetInrMin': targetInrMin,
        'targetInrMax': targetInrMax,
        'defaultMedicationTime': defaultMedicationTime,
        'testCycle': testCycle.toJson(),
        'testMethods': testMethods,
        'inrOffset': inrOffset,
      };
}
