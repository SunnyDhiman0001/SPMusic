import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_background/just_audio_background.dart';

import '../../domain/entities/playback_status.dart';
import 'audio_player_service.dart';

/// The only file in this project allowed to touch `package:just_audio`
/// directly. Everything else depends on [AudioPlayerService].
class JustAudioPlayerService implements AudioPlayerService {
  JustAudioPlayerService() : _player = ja.AudioPlayer() {
    _configureSession();
  }

  final ja.AudioPlayer _player;

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
    await _player.setAudioSource(
      ja.AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: metadata.id,
          title: metadata.title,
          artist: metadata.artist,
          album: metadata.album,
          artUri: metadata.artUri,
        ),
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
