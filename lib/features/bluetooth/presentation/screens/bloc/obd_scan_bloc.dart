import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/services/obd_service.dart';

// Events
abstract class ObdScanEvent extends Equatable {
  const ObdScanEvent();
  @override
  List<Object?> get props => [];
}

class StartObdScan extends ObdScanEvent {}

class ResetObdScan extends ObdScanEvent {}

// States
abstract class ObdScanState extends Equatable {
  const ObdScanState();
  @override
  List<Object?> get props => [];
}

class ObdScanInitial extends ObdScanState {}

class ObdScanning extends ObdScanState {}

class ObdScanLoaded extends ObdScanState {
  final List<DiagnosticIssue> issues;
  final int healthScore;

  const ObdScanLoaded({required this.issues, required this.healthScore});

  @override
  List<Object?> get props => [issues, healthScore];
}

class ObdScanError extends ObdScanState {
  final String message;

  const ObdScanError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ObdScanBloc extends Bloc<ObdScanEvent, ObdScanState> {
  final ObdService _obdService;

  ObdScanBloc(this._obdService) : super(ObdScanInitial()) {
    on<StartObdScan>((event, emit) async {
      emit(ObdScanning());
      try {
        final codesToScan = ['P0420', 'P0171', 'P0456'];
        final List<DiagnosticIssue> issues = [];

        for (final code in codesToScan) {
          try {
            final detail = await _obdService.getCodeDetail(code);
            issues.add(detail);
          } catch (_) {
            // Allow individual details to fail if needed
          }
        }

        // Calculate dynamic health score
        int healthScore = 100;
        for (final issue in issues) {
          if (issue.severity == DiagnosticSeverity.critical) {
            healthScore -= 15;
          } else if (issue.severity == DiagnosticSeverity.warning) {
            healthScore -= 8;
          } else {
            healthScore -= 4;
          }
        }
        healthScore = healthScore.clamp(0, 100);

        emit(ObdScanLoaded(issues: issues, healthScore: healthScore));
      } catch (e) {
        emit(ObdScanError(e.toString()));
      }
    });

    on<ResetObdScan>((event, emit) {
      emit(ObdScanInitial());
    });
  }
}
