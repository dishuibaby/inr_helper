import '../../domain/models/home_summary.dart';
import '../../domain/models/inr.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/settings.dart';

abstract interface class ApiClient {
  Future<HomeSummary> fetchHomeSummary();
  Future<MedicationRecord> createMedicationRecord(CreateMedicationRecordRequest request);
  Future<List<InrRecord>> fetchInrRecords();
  Future<InrRecord> createInrRecord(CreateInrRecordRequest request);
  Future<UserSettings> fetchSettings();
  Future<UserSettings> updateSettings(UserSettings settings);
}
