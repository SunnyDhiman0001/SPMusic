import '../../domain/entities/equalizer_band.dart';

/// Equalizer control on the active playback engine. Only the real engine
/// effect is exposed here; nothing is simulated.
abstract class EqualizerService {
  /// False on platforms whose engine has no equalizer (e.g. iOS).
  bool get isSupported;

  /// Completes once the engine has a loaded audio session to attach to
  /// (i.e. after the first song is loaded).
  Future<EqualizerParameters> get parameters;

  Future<void> setEnabled(bool enabled);
  Future<void> setBandGain(int bandIndex, double gainDb);
}
