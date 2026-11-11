import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_background/just_audio_background.dart';

import '../../../equalizer/data/services/equalizer_service.dart';
import '../../../equalizer/domain/entities/equalizer_band.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/repeat_mode.dart';
import 'audio_player_service.dart';

/// The only file in this project allowed to touch `package:just_audio`
/// directly. Everything else depends on [AudioPlayerService].
class JustAudioPlayerService
    implements AudioPlayerService, BackgroundAudioPlayerService, EqualizerService {
  JustAudioPlayerService() : this._(Platform.isAndroid ? ja.AndroidEqualizer() : null);

  JustAudioPlayerService._(this._equalizer)
      : _player = ja.AudioPlayer(
          audioPipeline: _equalizer == null ? null : ja.AudioPipeline(androidAudioEffects: [_equalizer]),
        ) {
    _configureSession();
  }

  final ja.AudioPlayer _player;
  final ja.AndroidEqualizer? _equalizer;

  @override
  bool get isSupported => _equalizer != null;

  @override
  Future<EqualizerParameters> get parameters async {
    final params = await _equalizer!.parameters;
    return EqualizerParameters(
      minDb: params.minDecibels,
      maxDb: params.maxDecibels,
      bands: [
        for (final b in params.bands)
          EqualizerBand(index: b.index, centerFrequencyHz: b.centerFrequency, gainDb: b.gain),
      ],
    );
  }

  @override
  Future<void> setEnabled(bool enabled) async => _equalizer?.setEnabled(enabled);

  @override
  Future<void> setBandGain(int bandIndex, double gainDb) async {
    final params = await _equalizer!.parameters;
    await params.bands[bandIndex].setGain(gainDb);
  }

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<PlaybackStatus> get statusStream => _player.playerStateStream.map(_mapStatus);

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  PlaybackStatus _mapStatus(ja.PlayerState state) {
    if (state.processingState == ja.ProcessingState.loading) {
      return PlaybackStatus.loading;
    }
    if (state.processingState == ja.ProcessingState.buffering) {
      return PlaybackStatus.buffering;
    }
    if (state.processingState == ja.ProcessingState.completed) {
      return PlaybackStatus.completed;
    }
    if (state.processingState == ja.ProcessingState.idle) {
      return PlaybackStatus.idle;
    }
    return state.playing ? PlaybackStatus.playing : PlaybackStatus.paused;
  }

  @override
  Future<void> load(String url, TrackMetadata metadata) async {
    await _player.setAudioSource(_audioSource(AudioQueueItem(url: url, metadata: metadata)));
  }

  @override
  Future<void> loadQueue(List<AudioQueueItem> queue, {required int initialIndex}) async {
    if (queue.isEmpty) return;
    await _player.setAudioSource(
      ja.ConcatenatingAudioSource(
        children: queue.map(_audioSource).toList(growable: false),
      ),
      initialIndex: initialIndex,
    );
  }

  ja.AudioSource _audioSource(AudioQueueItem item) {
    final metadata = item.metadata;
    return ja.AudioSource.uri(
      Uri.parse(item.url),
      tag: MediaItem(
        id: metadata.id,
        title: metadata.title,
        artist: metadata.artist,
        album: metadata.album,
        artUri: metadata.artUri,
      ),
    );
  }

  /// just_audio's `play()` future only completes when playback pauses or
  /// ends, so awaiting it directly would keep every caller (and any
  /// "is a load in flight" flag) busy for the whole song. Return as soon as
  /// playback has actually started, but still surface an early failure.
  @override
  Future<void> play() async {
    final finished = _player.play();
    await Future.any<void>([
      finished,
      _player.playerStateStream.firstWhere((s) => s.playing),
    ]);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setShuffleEnabled(bool enabled) async {
    if (enabled && !_player.shuffleModeEnabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(RepeatMode mode) => _player.setLoopMode(switch (mode) {
        RepeatMode.off => ja.LoopMode.off,
        RepeatMode.all => ja.LoopMode.all,
        RepeatMode.one => ja.LoopMode.one,
      });

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
