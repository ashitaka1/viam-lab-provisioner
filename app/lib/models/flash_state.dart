import '../core/disk_utils.dart';

enum FlashPhase {
  idle,
  awaitInsert,
  detected,
  flashing,
  done,
  error,
}

class FlashState {
  const FlashState({
    this.phase = FlashPhase.idle,
    this.machineName,
    this.detectedDisk,
    this.progressLines = const [],
    this.error,
    this.flashedNames = const [],
  });

  final FlashPhase phase;
  final String? machineName;
  final DiskInfo? detectedDisk;
  final List<String> progressLines;
  final String? error;
  final List<String> flashedNames;

  FlashState copyWith({
    FlashPhase? phase,
    String? machineName,
    DiskInfo? detectedDisk,
    List<String>? progressLines,
    String? error,
    List<String>? flashedNames,
    bool clearDisk = false,
    bool clearError = false,
  }) {
    return FlashState(
      phase: phase ?? this.phase,
      machineName: machineName ?? this.machineName,
      detectedDisk: clearDisk ? null : (detectedDisk ?? this.detectedDisk),
      progressLines: progressLines ?? this.progressLines,
      error: clearError ? null : (error ?? this.error),
      flashedNames: flashedNames ?? this.flashedNames,
    );
  }
}
