import 'package:flutter_test/flutter_test.dart';
import 'package:warfarin_inr_app/domain/models/home_summary.dart';
import 'package:warfarin_inr_app/domain/models/inr.dart';

void main() {
  test('parses home summary contract fields', () {
    final summary = HomeSummary.fromJson({
      'prominentReminder': {'level': 'strong', 'title': '今日待服药', 'body': '请记录'},
      'latestInr': {
        'id': 'inr-1',
        'rawValue': 2.1,
        'correctedValue': 2.2,
        'abnormalTier': 'normal',
        'testMethod': 'hospital_lab',
        'testedAt': '2026-04-24T08:00:00Z',
      },
      'nextTestAt': '2026-05-01T08:00:00Z',
      'todayMedication': {'status': 'pending', 'plannedDoseTablets': 1.5},
    });

    expect(summary.latestInr?.testMethod, TestMethod.hospitalLab);
    expect(summary.todayMedication.plannedDoseTablets, 1.5);
  });
}
