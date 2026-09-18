import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';

enum ScanPhase { idle, analyzing, result }

abstract class ScanEvent extends Equatable {
  const ScanEvent();
  @override
  List<Object?> get props => [];
}

class ScanStarted extends ScanEvent {
  const ScanStarted();
}

class ScanBrowsePressed extends ScanEvent {
  const ScanBrowsePressed();
}

class ScanCameraPressed extends ScanEvent {
  const ScanCameraPressed();
}

class ScanAnotherPressed extends ScanEvent {
  const ScanAnotherPressed();
}

class ScanState extends Equatable {
  const ScanState({
    this.phase = ScanPhase.idle,
    this.recentScans = const [],
    this.photoTips = const [],
    this.progress = 0,
    this.result,
  });

  final ScanPhase phase;
  final List<CropScan> recentScans;
  final List<String> photoTips;
  final double progress;
  final DiseaseResult? result;

  ScanState copyWith({
    ScanPhase? phase,
    List<CropScan>? recentScans,
    List<String>? photoTips,
    double? progress,
    DiseaseResult? result,
    bool clearResult = false,
  }) {
    return ScanState(
      phase: phase ?? this.phase,
      recentScans: recentScans ?? this.recentScans,
      photoTips: photoTips ?? this.photoTips,
      progress: progress ?? this.progress,
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [phase, recentScans, photoTips, progress, result];
}

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc() : super(const ScanState()) {
    on<ScanStarted>((event, emit) {
      emit(
        ScanState(
          recentScans: List.of(DummyData.recentScans),
          photoTips: List.of(DummyData.photoTips),
        ),
      );
    });
    on<ScanBrowsePressed>(_onAnalyze);
    on<ScanCameraPressed>(_onAnalyze);
    on<ScanAnotherPressed>((event, emit) {
      emit(
        state.copyWith(
          phase: ScanPhase.idle,
          progress: 0,
          clearResult: true,
        ),
      );
    });
  }

  Future<void> _onAnalyze(
    ScanEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(state.copyWith(phase: ScanPhase.analyzing, progress: 0));
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      emit(state.copyWith(phase: ScanPhase.analyzing, progress: i / 10));
    }
    emit(
      state.copyWith(
        phase: ScanPhase.result,
        progress: 1,
        result: DummyData.diseaseResult,
      ),
    );
  }
}
