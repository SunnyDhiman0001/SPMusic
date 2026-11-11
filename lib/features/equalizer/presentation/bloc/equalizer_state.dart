import '../../domain/entities/equalizer_band.dart';

enum EqualizerStatus { unsupported, waitingForAudio, ready }

class EqualizerState {
  const EqualizerState({
    this.status = EqualizerStatus.waitingForAudio,
    this.enabled = true,
    this.minDb = -12,
    this.maxDb = 12,
    this.bands = const [],
    this.presetId,
  });

  final EqualizerStatus status;
  final bool enabled;
  final double minDb;
  final double maxDb;
  final List<EqualizerBand> bands;

  /// Selected preset id, or null when the user has customized the bands.
  final String? presetId;

  EqualizerState copyWith({
    EqualizerStatus? status,
    bool? enabled,
    double? minDb,
    double? maxDb,
    List<EqualizerBand>? bands,
    Object? presetId = _keep,
  }) =>
      EqualizerState(
        status: status ?? this.status,
        enabled: enabled ?? this.enabled,
        minDb: minDb ?? this.minDb,
        maxDb: maxDb ?? this.maxDb,
        bands: bands ?? this.bands,
        presetId: identical(presetId, _keep) ? this.presetId : presetId as String?,
      );
}

const Object _keep = Object();
