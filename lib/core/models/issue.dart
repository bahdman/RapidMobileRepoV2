import 'package:flutter/material.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/config/app_assets.dart';

enum DiagnosticSeverity { critical, warning, info }

extension DiagnosticSeverityX on DiagnosticSeverity {
  String get label => switch (this) {
        DiagnosticSeverity.critical => 'HIGH',
        DiagnosticSeverity.warning => 'WARNING',
        DiagnosticSeverity.info => 'Low',
      };

  Color get color => switch (this) {
        DiagnosticSeverity.critical => AppColors.red,
        DiagnosticSeverity.warning => AppColors.yellow,
        DiagnosticSeverity.info => AppColors.blue,
      };

  Color get bgColor => switch (this) {
        DiagnosticSeverity.critical => const Color(0xFFFFD3CC),
        DiagnosticSeverity.warning => const Color(0xFFFFF8CD),
        DiagnosticSeverity.info => const Color(0xFFCCDCEF),
      };

  String get icon => switch (this) {
        DiagnosticSeverity.critical => Assets.danger,
        DiagnosticSeverity.warning => Assets.warningTriangle,
        DiagnosticSeverity.info => Assets.infoCircleBlue,
      };
}

class DiagnosticIssue {
  final String code;
  final String title;
  final DiagnosticSeverity severity;
  final String description;
  final String recommendedAction;
  final String estimatedCost;
  final List<String> possibleCauses;
  final bool unsafeToDrive;

  const DiagnosticIssue({
    required this.code,
    required this.title,
    required this.severity,
    required this.description,
    required this.recommendedAction,
    required this.estimatedCost,
    required this.possibleCauses,
    this.unsafeToDrive = false,
  });
}
