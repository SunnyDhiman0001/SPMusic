import 'dart:math' as math;

/// A named EQ curve, described by gains at a few anchor frequencies so it can
/// be mapped onto however many bands the device exposes (usually 5, but it
/// varies by hardware).
class EqualizerPreset {
  const EqualizerPreset(this.id, this.name, this._anchors);

  final String id;
  final String name;
  final List<(double hz, double db)> _anchors;

  /// Gain in dB for [frequencyHz], linearly interpolated over log-frequency.
  double gainAt(double frequencyHz) {
    final a = _anchors;
    if (frequencyHz <= a.first.$1) return a.first.$2;
    if (frequencyHz >= a.last.$1) return a.last.$2;
    for (var i = 0; i < a.length - 1; i++) {
      final (loHz, loDb) = a[i];
      final (hiHz, hiDb) = a[i + 1];
      if (frequencyHz <= hiHz) {
        final t = (math.log(frequencyHz) - math.log(loHz)) / (math.log(hiHz) - math.log(loHz));
        return loDb + (hiDb - loDb) * t;
      }
    }
    return a.last.$2;
  }

  static const normal = EqualizerPreset('normal', 'Normal', [(60, 0), (14000, 0)]);
  static const rock = EqualizerPreset('rock', 'Rock', [(60, 5), (230, 3), (910, -2), (3600, 3), (14000, 5)]);
  static const pop = EqualizerPreset('pop', 'Pop', [(60, -1), (230, 2), (910, 4), (3600, 2), (14000, -1)]);
  static const jazz = EqualizerPreset('jazz', 'Jazz', [(60, 4), (230, 2), (910, -2), (3600, 2), (14000, 4)]);
  static const classical = EqualizerPreset('classical', 'Classical', [(60, 4), (230, 3), (910, -1), (3600, 3), (14000, 4)]);
  static const bassBoost = EqualizerPreset('bass_boost', 'Bass Boost', [(60, 6), (230, 4), (910, 0), (3600, 0), (14000, 0)]);
  static const trebleBoost = EqualizerPreset('treble_boost', 'Treble Boost', [(60, 0), (230, 0), (910, 0), (3600, 4), (14000, 6)]);

  static const all = [normal, rock, pop, jazz, classical, bassBoost, trebleBoost];

  static EqualizerPreset? byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
