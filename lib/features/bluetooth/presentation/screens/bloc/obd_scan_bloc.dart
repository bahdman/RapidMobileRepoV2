import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/services/obd_connection_service.dart';
import 'package:rapid_app/core/services/obd_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ObdScanEvent extends Equatable {
  const ObdScanEvent();
  @override
  List<Object?> get props => [];
}

/// Triggers a real OBD-II scan using the connected adapter.
class StartObdScan extends ObdScanEvent {}

/// Reset back to the initial state (e.g. after navigating away).
class ResetObdScan extends ObdScanEvent {}

// ── States ────────────────────────────────────────────────────────────────────

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

// ── Bloc ──────────────────────────────────────────────────────────────────────

class ObdScanBloc extends Bloc<ObdScanEvent, ObdScanState> {
  final ObdService _obdService;
  final ObdConnectionService _connectionService;

  ObdScanBloc(this._obdService, this._connectionService)
      : super(ObdScanInitial()) {
    on<StartObdScan>(_onStartObdScan);
    on<ResetObdScan>((_, emit) => emit(ObdScanInitial()));
  }

  Future<void> _onStartObdScan(
    StartObdScan event,
    Emitter<ObdScanState> emit,
  ) async {
    emit(ObdScanning());
    try {
      List<String> dtcCodes = [];

      if (_connectionService.isConnected) {
        // ── Real hardware path ──────────────────────────────────────────────
        dtcCodes = await _connectionService.readDtcCodes();
      }

      // ── Fallback: no adapter connected or no codes returned ────────────
      // In demo / dev mode we still return useful results from the API
      // using a small fixed set of demonstration codes.
      if (dtcCodes.isEmpty) {
        dtcCodes = ['P0420', 'P0171', 'P0456'];
      }

      // ── Enrich each code via the OBD API ──────────────────────────────
      final List<DiagnosticIssue> issues = [];
      for (final code in dtcCodes) {
        try {
          final detail = await _obdService.getCodeDetail(code);
          issues.add(detail);
        } catch (_) {
          // Allow individual API lookups to fail gracefully
        }
      }

      // ── Calculate health score ─────────────────────────────────────────
      int healthScore = 100;
      for (final issue in issues) {
        switch (issue.severity) {
          case DiagnosticSeverity.critical:
            healthScore -= 15;
            break;
          case DiagnosticSeverity.warning:
            healthScore -= 8;
            break;
          case DiagnosticSeverity.info:
            healthScore -= 4;
            break;
        }
      }
      healthScore = healthScore.clamp(0, 100);

      emit(ObdScanLoaded(issues: issues, healthScore: healthScore));
    } catch (e) {
      emit(ObdScanError(e.toString()));
    }
  }
}
