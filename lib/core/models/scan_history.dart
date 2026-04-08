import 'issue.dart';

class ScanHistory {
  final String id;
  final DateTime date;
  final String issueCode;
  final String? customDescription;
  final DiagnosticSeverity severity;

  const ScanHistory({
    required this.id,
    required this.date,
    required this.issueCode,
    required this.severity,
    this.customDescription,
  });
}
