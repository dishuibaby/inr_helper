import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/home_summary.dart';
import '../../domain/models/inr.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/settings.dart';
import 'api_client.dart';
import 'api_exception.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({required String baseUrl, http.Client? client})
      : _baseUri = Uri.parse(baseUrl),
        _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  @override
  Future<HomeSummary> fetchHomeSummary() async {
    final json = await _getJson('/home/summary');
    return HomeSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<MedicationRecord> createMedicationRecord(CreateMedicationRecordRequest request) async {
    final json = await _postJson('/medication/records', request.toJson());
    return MedicationRecord.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<InrRecord>> fetchInrRecords() async {
    final json = await _getJson('/inr/records') as Map<String, dynamic>;
    final records = json['records'] as List<dynamic>? ?? const [];
    return records.map((item) => InrRecord.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<InrRecord> createInrRecord(CreateInrRecordRequest request) async {
    final json = await _postJson('/inr/records', request.toJson());
    return InrRecord.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<UserSettings> fetchSettings() async {
    final json = await _getJson('/settings');
    return UserSettings.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<UserSettings> updateSettings(UserSettings settings) async {
    final json = await _putJson('/settings', settings.toJson());
    return UserSettings.fromJson(json as Map<String, dynamic>);
  }

  Future<dynamic> _getJson(String path) async {
    final response = await _client.get(_resolve(path));
    return _decodeEnvelope(response);
  }

  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _resolve(path),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeEnvelope(response);
  }

  Future<dynamic> _putJson(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      _resolve(path),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeEnvelope(response);
  }

  Uri _resolve(String path) {
    final basePath = _baseUri.path.endsWith('/') ? _baseUri.path.substring(0, _baseUri.path.length - 1) : _baseUri.path;
    return _baseUri.replace(path: '$basePath$path');
  }

  dynamic _decodeEnvelope(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['message'] as String? ?? 'Request failed', statusCode: response.statusCode);
    }
    if ((decoded['code'] as int? ?? 0) != 0) {
      throw ApiException(decoded['message'] as String? ?? 'API error', statusCode: response.statusCode);
    }
    return decoded['data'];
  }
}
