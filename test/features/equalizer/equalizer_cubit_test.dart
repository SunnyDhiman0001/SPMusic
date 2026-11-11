import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmusic/features/equalizer/data/services/equalizer_service.dart';
import 'package:spmusic/features/equalizer/domain/entities/equalizer_band.dart';
import 'package:spmusic/features/equalizer/domain/entities/equalizer_preset.dart';
import 'package:spmusic/features/equalizer/presentation/bloc/equalizer_cubit.dart';
import 'package:spmusic/features/equalizer/presentation/bloc/equalizer_state.dart';

class FakeEqualizerService implements EqualizerService {
  FakeEqualizerService({this.isSupported = true});

  @override
  final bool isSupported;

  final _params = Completer<EqualizerParameters>();
  final gains = <int, double>{};
  bool? enabled;

  void audioLoaded() => _params.complete(EqualizerParameters(
        minDb: -10,
        maxDb: 10,
        bands: [
          for (final (i, hz) in [60.0, 230.0, 910.0, 3600.0, 14000.0].indexed)
            EqualizerBand(index: i, centerFrequencyHz: hz, gainDb: 0),
        ],
      ));

  @override
  Future<EqualizerParameters> get parameters => _params.future;

  @override
  Future<void> setEnabled(bool value) async => enabled = value;

  @override
  Future<void> setBandGain(int bandIndex, double gainDb) async => gains[bandIndex] = gainDb;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('preset curves interpolate over frequency and hit their anchors', () {
    expect(EqualizerPreset.bassBoost.gainAt(60), 6);
    expect(EqualizerPreset.trebleBoost.gainAt(14000), 6);
    expect(EqualizerPreset.normal.gainAt(1000), 0);
    final mid = EqualizerPreset.rock.gainAt(120); // between 60Hz (5) and 230Hz (3)
    expect(mid, inExclusiveRange(3, 5));
  });

  test('unsupported platform reports unsupported', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = EqualizerCubit(FakeEqualizerService(isSupported: false), await SharedPreferences.getInstance());
    expect(cubit.state.status, EqualizerStatus.unsupported);
    await cubit.close();
  });

  test('waits for audio, then applies preset and custom gains to the engine', () async {
    SharedPreferences.setMockInitialValues({});
    final service = FakeEqualizerService();
    final cubit = EqualizerCubit(service, await SharedPreferences.getInstance());
    expect(cubit.state.status, EqualizerStatus.waitingForAudio);

    service.audioLoaded();
    await _settle();
    expect(cubit.state.status, EqualizerStatus.ready);
    expect(cubit.state.bands, hasLength(5));

    await cubit.selectPreset(EqualizerPreset.bassBoost);
    expect(service.gains[0], 6);
    expect(cubit.state.presetId, 'bass_boost');

    await cubit.setBandGain(4, 20); // clamps to device max
    expect(service.gains[4], 10);
    expect(cubit.state.presetId, isNull);

    await cubit.reset();
    expect(service.gains.values.every((g) => g == 0), isTrue);
    await cubit.close();
  });

  test('restores saved settings after a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final first = FakeEqualizerService();
    final cubit = EqualizerCubit(first, prefs);
    first.audioLoaded();
    await _settle();
    await cubit.setEnabled(false);
    await cubit.setBandGain(2, 3.5);
    await cubit.persist();
    await cubit.close();

    final second = FakeEqualizerService();
    final restarted = EqualizerCubit(second, prefs);
    second.audioLoaded();
    await _settle();
    await _settle();
    expect(second.gains[2], 3.5);
    expect(second.enabled, isFalse);
    expect(restarted.state.presetId, isNull);
    await restarted.close();
  });
}
