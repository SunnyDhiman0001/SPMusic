import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/equalizer_service.dart';
import '../../domain/entities/equalizer_band.dart';
import '../../domain/entities/equalizer_preset.dart';
import 'equalizer_state.dart';

const _enabledKey = 'eq_enabled';
const _presetKey = 'eq_preset';
const _gainsKey = 'eq_gains';

/// Owns equalizer settings. Changes go straight to the engine (real time)
/// and are persisted so they survive an app restart.
class EqualizerCubit extends Cubit<EqualizerState> {
  EqualizerCubit(this._service, this._prefs)
      : super(EqualizerState(
          status: _service.isSupported ? EqualizerStatus.waitingForAudio : EqualizerStatus.unsupported,
          enabled: _prefs.getBool(_enabledKey) ?? true,
          presetId: _prefs.containsKey(_gainsKey) ? _prefs.getString(_presetKey) : 'normal',
        )) {
    if (_service.isSupported) unawaited(_attach());
  }

  final EqualizerService _service;
  final SharedPreferences _prefs;

  /// The engine only exposes its bands once audio is loaded, so wait for that
  /// then push the saved settings onto it.
  Future<void> _attach() async {
    final params = await _service.parameters;
    if (isClosed) return;
    var bands = params.bands;
    String? presetId = state.presetId;
    final saved = _readSavedGains();
    if (saved != null && saved.length == bands.length) {
      bands = [
        for (final b in bands) b.copyWith(gainDb: saved[b.index].clamp(params.minDb, params.maxDb).toDouble()),
      ];
    } else {
      // Nothing saved, or the band layout differs from when it was saved.
      final preset = EqualizerPreset.byId(presetId) ?? EqualizerPreset.normal;
      presetId = preset.id;
      bands = _bandsForPreset(preset, bands, params.minDb, params.maxDb);
    }
    emit(state.copyWith(
      status: EqualizerStatus.ready,
      minDb: params.minDb,
      maxDb: params.maxDb,
      bands: bands,
      presetId: presetId,
    ));
    await _service.setEnabled(state.enabled);
    for (final b in bands) {
      await _service.setBandGain(b.index, b.gainDb);
    }
  }

  List<double>? _readSavedGains() {
    final raw = _prefs.getString(_gainsKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    } catch (_) {
      return null;
    }
  }

  static List<EqualizerBand> _bandsForPreset(
    EqualizerPreset preset,
    List<EqualizerBand> bands,
    double minDb,
    double maxDb,
  ) =>
      [
        for (final b in bands)
          b.copyWith(gainDb: preset.gainAt(b.centerFrequencyHz).clamp(minDb, maxDb).toDouble()),
      ];

  Future<void> setEnabled(bool enabled) async {
    emit(state.copyWith(enabled: enabled));
    await _service.setEnabled(enabled);
    await _prefs.setBool(_enabledKey, enabled);
  }

  Future<void> selectPreset(EqualizerPreset preset) async {
    if (state.status != EqualizerStatus.ready) return;
    final bands = _bandsForPreset(preset, state.bands, state.minDb, state.maxDb);
    emit(state.copyWith(bands: bands, presetId: preset.id));
    for (final b in bands) {
      await _service.setBandGain(b.index, b.gainDb);
    }
    await persist();
  }

  Future<void> setBandGain(int index, double gainDb) async {
    if (state.status != EqualizerStatus.ready) return;
    final gain = gainDb.clamp(state.minDb, state.maxDb).toDouble();
    final bands = [for (final b in state.bands) b.index == index ? b.copyWith(gainDb: gain) : b];
    emit(state.copyWith(bands: bands, presetId: null));
    await _service.setBandGain(index, gain);
  }

  /// Persist once a drag ends rather than on every slider tick.
  Future<void> persist() async {
    await _prefs.setString(_gainsKey, jsonEncode([for (final b in state.bands) b.gainDb]));
    final id = state.presetId;
    if (id == null) {
      await _prefs.remove(_presetKey);
    } else {
      await _prefs.setString(_presetKey, id);
    }
  }

  Future<void> reset() => selectPreset(EqualizerPreset.normal);
}
