import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/api/http_api_client.dart';
import '../core/api/mock_api_client.dart';
import '../core/config/app_config.dart';
import '../domain/models/home_summary.dart';
import '../domain/models/inr.dart';
import '../domain/models/medication.dart';
import '../domain/models/settings.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final apiClientProvider = Provider<ApiClient>((ref) {
  const useMock = bool.fromEnvironment('USE_MOCK_API', defaultValue: true);
  if (useMock) return MockApiClient();
  final config = ref.watch(appConfigProvider);
  return HttpApiClient(baseUrl: config.apiBaseUrl);
});

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) {
  return ref.watch(apiClientProvider).fetchHomeSummary();
});

final inrRecordsProvider = FutureProvider<List<InrRecord>>((ref) {
  return ref.watch(apiClientProvider).fetchInrRecords();
});

final settingsProvider = FutureProvider<UserSettings>((ref) {
  return ref.watch(apiClientProvider).fetchSettings();
});

final medicationActionsProvider = AsyncNotifierProvider<MedicationActionsController, MedicationRecord?>(
  MedicationActionsController.new,
);

class MedicationActionsController extends AsyncNotifier<MedicationRecord?> {
  @override
  Future<MedicationRecord?> build() async => null;

  Future<void> record(CreateMedicationRecordRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final record = await ref.read(apiClientProvider).createMedicationRecord(request);
      ref.invalidate(homeSummaryProvider);
      return record;
    });
  }
}

final inrActionsProvider = AsyncNotifierProvider<InrActionsController, InrRecord?>(
  InrActionsController.new,
);

class InrActionsController extends AsyncNotifier<InrRecord?> {
  @override
  Future<InrRecord?> build() async => null;

  Future<void> record(CreateInrRecordRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final record = await ref.read(apiClientProvider).createInrRecord(request);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(inrRecordsProvider);
      return record;
    });
  }
}
