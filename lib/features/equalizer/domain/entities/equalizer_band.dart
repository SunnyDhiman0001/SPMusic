/// One adjustable frequency band as reported by the playback engine.
class EqualizerBand {
  const EqualizerBand({required this.index, required this.centerFrequencyHz, required this.gainDb});

  final int index;
  final double centerFrequencyHz;
  final double gainDb;

  EqualizerBand copyWith({double? gainDb}) =>
      EqualizerBand(index: index, centerFrequencyHz: centerFrequencyHz, gainDb: gainDb ?? this.gainDb);

  /// "60 Hz" / "3.6 kHz" label for the UI.
  String get label {
    if (centerFrequencyHz >= 1000) {
      final khz = centerFrequencyHz / 1000;
      return '${khz.toStringAsFixed(khz >= 10 || khz == khz.roundToDouble() ? 0 : 1)} kHz';
    }
    return '${centerFrequencyHz.round()} Hz';
  }
}

/// Band layout and gain range reported by the device's equalizer.
class EqualizerParameters {
  const EqualizerParameters({required this.minDb, required this.maxDb, required this.bands});

  final double minDb;
  final double maxDb;
  final List<EqualizerBand> bands;
}
