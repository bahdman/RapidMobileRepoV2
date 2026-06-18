import 'package:intl/intl.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/core/config/issue_database.dart';

class ObdSearchResult {
  final String code;
  final String primaryCause;
  final String faultDescription;
  final String priority;

  const ObdSearchResult({
    required this.code,
    required this.primaryCause,
    required this.faultDescription,
    required this.priority,
  });

  factory ObdSearchResult.fromJson(Map<String, dynamic> json) {
    return ObdSearchResult(
      code: json['code'] as String? ?? '',
      primaryCause: json['primaryCause'] as String? ?? '',
      faultDescription: json['faultDescription'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
    );
  }
}

class ObdService {
  final ApiService _apiService;
  final Map<String, DiagnosticIssue> _cache = {};

  ObdService(this._apiService);

  Future<List<ObdSearchResult>> searchCodes(String query) async {
    try {
      final response = await _apiService.get(
        ApiConfig.obdSearch,
        queryParameters: {'q': query},
      );

      final data = response.data;
      if (data == null) return [];

      if (data is List) {
        return data
            .map(
              (item) => ObdSearchResult.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list
            .map(
              (item) => ObdSearchResult.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<DiagnosticIssue> getCodeDetail(String code) async {
    if (_cache.containsKey(code)) {
      return _cache[code]!;
    }

    try {
      final response = await _apiService.get(ApiConfig.obdCodeDetail(code));

      final data = response.data;
      if (data == null) {
        throw Exception('No data found for code $code');
      }

      Map<String, dynamic> jsonMap;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          jsonMap = data['data'] as Map<String, dynamic>;
        } else {
          jsonMap = data;
        }
      } else {
        throw Exception('Invalid response structure');
      }

      final apiCode = jsonMap['code'] as String? ?? code;
      final vehicleSegments =
          (jsonMap['vehicleSegments'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final primaryReason = jsonMap['primaryReason'] as String? ?? '';
      final priority = jsonMap['priority'] as String? ?? '';
      final estimatedRepairCost =
          jsonMap['estimatedRepairCost'] as String? ?? '';
      final possibleCauses =
          (jsonMap['possibleCauses'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      String formattedCost = estimatedRepairCost;
      if (estimatedRepairCost.isNotEmpty) {
        try {
          final doubleCost = double.parse(
            estimatedRepairCost.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
          formattedCost = NumberFormat.currency(
            symbol: '₦',
            decimalDigits: 2,
          ).format(doubleCost);
        } catch (e) {
          // Keep original string if parsing fails
        }
      }

      DiagnosticSeverity severity;
      switch (priority.toLowerCase()) {
        case 'critical':
        case 'high':
          severity = DiagnosticSeverity.critical;
          break;
        case 'warning':
        case 'medium':
          severity = DiagnosticSeverity.warning;
          break;
        case 'info':
        case 'low':
        default:
          severity = DiagnosticSeverity.info;
      }

      final localIssue = IssueDatabase.getIssue(apiCode);

      final result = DiagnosticIssue(
        code: apiCode,
        title: primaryReason.isNotEmpty
            ? primaryReason
            : (localIssue?.title ?? 'Unknown Diagnostic Issue'),
        severity: severity,
        description:
            localIssue?.description ??
            (vehicleSegments.isNotEmpty
                ? 'This code indicates an issue affecting the following vehicle segments: ${vehicleSegments.join(", ")}.'
                : 'Diagnostic code $apiCode indicates a vehicle fault.'),
        recommendedAction:
            localIssue?.recommendedAction ??
            (possibleCauses.isNotEmpty
                ? 'We recommend checking the following components: ${possibleCauses.join(", ")}. Consult a mechanic for further inspection.'
                : 'Please consult a mechanic to perform detailed vehicle diagnostics.'),
        estimatedCost: formattedCost.isNotEmpty
            ? formattedCost
            : (localIssue?.estimatedCost ?? 'Unknown cost'),
        possibleCauses: possibleCauses.isNotEmpty
            ? possibleCauses
            : (localIssue?.possibleCauses ?? []),
        unsafeToDrive:
            localIssue?.unsafeToDrive ??
            (severity == DiagnosticSeverity.critical),
      );

      _cache[code] = result;
      return result;
    } catch (e) {
      final localIssue = IssueDatabase.getIssue(code);
      if (localIssue != null) {
        return localIssue;
      }
      rethrow;
    }
  }
}
