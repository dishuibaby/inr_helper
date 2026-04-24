enum MedicationActionType { taken, paused, missed }
enum TomorrowDoseMode { planned, manual }
enum MedicationStatus { pending, taken, paused, missed }

T _enumFromJson<T extends Enum>(List<T> values, String? value, T fallback) {
  return values.firstWhere((item) => item.name == value, orElse: () => fallback);
}

class TodayMedication {
  const TodayMedication({required this.status, required this.plannedDoseTablets});

  factory TodayMedication.fromJson(Map<String, dynamic> json) {
    return TodayMedication(
      status: _enumFromJson(MedicationStatus.values, json['status'] as String?, MedicationStatus.pending),
      plannedDoseTablets: (json['plannedDoseTablets'] as num? ?? 0).toDouble(),
    );
  }

  final MedicationStatus status;
  final double plannedDoseTablets;
}

class MedicationRecord {
  const MedicationRecord({
    required this.id,
    required this.actionType,
    required this.actualDoseTablets,
    required this.recordedAt,
    required this.tomorrowDoseMode,
    this.tomorrowDoseTablets,
  });

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id'] as String? ?? '',
      actionType: _enumFromJson(MedicationActionType.values, json['actionType'] as String?, MedicationActionType.taken),
      actualDoseTablets: (json['actualDoseTablets'] as num? ?? 0).toDouble(),
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      tomorrowDoseMode: _enumFromJson(TomorrowDoseMode.values, json['tomorrowDoseMode'] as String?, TomorrowDoseMode.planned),
      tomorrowDoseTablets: (json['tomorrowDoseTablets'] as num?)?.toDouble(),
    );
  }

  final String id;
  final MedicationActionType actionType;
  final double actualDoseTablets;
  final DateTime recordedAt;
  final TomorrowDoseMode tomorrowDoseMode;
  final double? tomorrowDoseTablets;
}

class CreateMedicationRecordRequest {
  const CreateMedicationRecordRequest({
    required this.actionType,
    required this.actualDoseTablets,
    required this.tomorrowDoseMode,
    this.tomorrowDoseTablets,
  });

  final MedicationActionType actionType;
  final double actualDoseTablets;
  final TomorrowDoseMode tomorrowDoseMode;
  final double? tomorrowDoseTablets;

  Map<String, dynamic> toJson() => {
        'actionType': actionType.name,
        'actualDoseTablets': actualDoseTablets,
        'tomorrowDoseMode': tomorrowDoseMode.name,
        if (tomorrowDoseTablets != null) 'tomorrowDoseTablets': tomorrowDoseTablets,
      };
}
