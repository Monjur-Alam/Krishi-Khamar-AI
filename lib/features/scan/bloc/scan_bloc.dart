import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/scan_repository.dart';
import '../../../data/services/disease_detection_service.dart';

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

class ScanRecentOpened extends ScanEvent {
  const ScanRecentOpened(this.scan);
  final CropScan scan;
  @override
  List<Object?> get props => [scan];
}

class ScanState extends Equatable {
  const ScanState({
    this.phase = ScanPhase.idle,
    this.recentScans = const [],
    this.photoTips = const [],
    this.progress = 0,
    this.result,
    this.previewBytes,
    this.error,
  });

  final ScanPhase phase;
  final List<CropScan> recentScans;
  final List<String> photoTips;
  final double progress;
  final DiseaseResult? result;
  final List<int>? previewBytes;
  final String? error;

  ScanState copyWith({
    ScanPhase? phase,
    List<CropScan>? recentScans,
    List<String>? photoTips,
    double? progress,
    DiseaseResult? result,
    bool clearResult = false,
    List<int>? previewBytes,
    bool clearPreview = false,
    String? error,
    bool clearError = false,
  }) {
    return ScanState(
      phase: phase ?? this.phase,
      recentScans: recentScans ?? this.recentScans,
      photoTips: photoTips ?? this.photoTips,
      progress: progress ?? this.progress,
      result: clearResult ? null : (result ?? this.result),
      previewBytes: clearPreview ? null : (previewBytes ?? this.previewBytes),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [phase, recentScans, photoTips, progress, result, previewBytes, error];
}

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc({
    ScanRepository? scanRepository,
    DiseaseDetectionService? detectionService,
    ImagePicker? imagePicker,
  })  : _scanRepository = scanRepository ?? ScanRepository(),
        _detectionService = detectionService ?? DiseaseDetectionService(),
        _picker = imagePicker ?? ImagePicker(),
        super(const ScanState()) {
    on<ScanStarted>(_onStarted);
    on<ScanBrowsePressed>((e, emit) => _pickAndAnalyze(emit, ImageSource.gallery));
    on<ScanCameraPressed>((e, emit) => _pickAndAnalyze(emit, ImageSource.camera));
    on<ScanAnotherPressed>((event, emit) {
      emit(
        state.copyWith(
          phase: ScanPhase.idle,
          progress: 0,
          clearResult: true,
          clearPreview: true,
          clearError: true,
        ),
      );
    });
    on<ScanRecentOpened>((event, emit) {
      emit(
        state.copyWith(
          phase: ScanPhase.result,
          result: event.scan.toDiseaseResult(),
          clearError: true,
        ),
      );
    });
  }

  final ScanRepository _scanRepository;
  final DiseaseDetectionService _detectionService;
  final ImagePicker _picker;

  Future<void> _onStarted(ScanStarted event, Emitter<ScanState> emit) async {
    emit(
      state.copyWith(
        photoTips: List.of(DummyData.photoTips),
        phase: ScanPhase.idle,
      ),
    );
    try {
      final scans = await _scanRepository.getRecentScans();
      emit(state.copyWith(recentScans: scans));
    } catch (_) {
      emit(state.copyWith(recentScans: List.of(DummyData.recentScans)));
    }
  }

  Future<void> _pickAndAnalyze(
    Emitter<ScanState> emit,
    ImageSource source,
  ) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      emit(
        state.copyWith(
          phase: ScanPhase.analyzing,
          progress: 0.15,
          previewBytes: bytes,
          clearResult: true,
          clearError: true,
        ),
      );

      // Animate progress while API runs.
      var progress = 0.15;
      final ticker = Stream.periodic(const Duration(milliseconds: 350), (_) {
        progress = (progress + 0.08).clamp(0.15, 0.9);
        return progress;
      }).take(10);

      DiseaseResult? result;
      Object? error;
      final analyzeFuture = () async {
        try {
          final detected = await _detectionService.analyzeImage(bytes);
          final saved = await _scanRepository.saveScan(
            scan: detected,
            imageBytes: bytes,
          );
          result = saved.toDiseaseResult();
          return saved;
        } catch (e) {
          error = e;
          return null;
        }
      }();

      await for (final p in ticker) {
        if (result != null || error != null) break;
        emit(state.copyWith(phase: ScanPhase.analyzing, progress: p));
      }

      final saved = await analyzeFuture;
      if (saved != null) {
        final scans = await _scanRepository.getRecentScans();
        emit(
          state.copyWith(
            phase: ScanPhase.result,
            progress: 1,
            result: result,
            recentScans: scans,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            phase: ScanPhase.idle,
            progress: 0,
            clearPreview: true,
            error: error.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          phase: ScanPhase.idle,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
