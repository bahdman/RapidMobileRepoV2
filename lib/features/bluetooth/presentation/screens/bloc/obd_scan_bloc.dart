import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rapid_app/core/services/obd_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ObdScanEvent extends Equatable {
  const ObdScanEvent();
  @override
  List<Object?> get props => [];
}

/// Begin the OBD diagnostic scan on the already-connected adapter.
class StartObdScan extends ObdScanEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class ObdScanState extends Equatable {
  const ObdScanState();
  @override
  List<Object?> get props => [];
}

class ObdScanIdle extends ObdScanState {}

class ObdScanInProgress extends ObdScanState {
  /// Progress from 0.0 to 1.0
  final double progress;
  const ObdScanInProgress(this.progress);
  @override
  List<Object?> get props => [progress];
}

class ObdScanComplete extends ObdScanState {
  final ObdScanResult result;
  const ObdScanComplete(this.result);
  @override
  List<Object?> get props => [result];
}

class ObdScanFailed extends ObdScanState {
  final String message;
  const ObdScanFailed(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class ObdScanBloc extends Bloc<ObdScanEvent, ObdScanState> {
  final ObdService _obd = ObdService.instance;

  ObdScanBloc() : super(ObdScanIdle()) {
    on<StartObdScan>(_onStartObdScan);
  }

  Future<void> _onStartObdScan(
    StartObdScan event,
    Emitter<ObdScanState> emit,
  ) async {
    emit(const ObdScanInProgress(0.0));

    try {
      final result = await _obd.runDiagnosticScan(
        onProgress: (progress) {
          if (!isClosed) {
            // We emit directly using a local controller so we can push
            // progress updates inside the async callback.
            // The emitter is only valid during the handler, so we guard it.
            if (!emit.isDone) {
              emit(ObdScanInProgress(progress));
            }
          }
        },
      );

      emit(ObdScanComplete(result));
    } catch (e) {
      emit(ObdScanFailed('Scan failed: $e'));
    }
  }
}
