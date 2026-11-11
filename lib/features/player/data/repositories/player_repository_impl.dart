import '../../domain/entities/playback_status.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/repositories/player_repository.dart';
import '../services/audio_player_service.dart';

class PlayerRepositoryImpl implements PlayerRepository, BackgroundPlayerRepository {
  PlayerRepositoryImpl(this._service);

  final AudioPlayerService _service;

  /// Bumped on every load request. A request that finds a newer one has
  /// started stops before its next step, so it can never call play() on top
  /// of (or reconfigure) the newer song's source.
  int _loadToken = 0;

  @override
  Stream<Duration> get positionStream => _service.positionStream;

  @override
  Stream<Duration?> get durationStream => _service.durationStream;

  @override
  Stream<PlaybackStatus> get statusStream => _service.statusStream;

  BackgroundAudioPlayerService? get _background {
    final service = _service;
    return service is BackgroundAudioPlayerService ? service as BackgroundAudioPlayerService : null;
  }

  @override
  Stream<int?> get currentIndexStream =>
      _background?.currentIndexStream ?? const Stream<int?>.empty();

  @override
  Future<void> loadAndPlay(String url, TrackMetadata metadata) async {
    final token = ++_loadToken;
    await _service.pause();
    if (token != _loadToken) return;
    await _service.load(url, metadata);
    if (token != _loadToken) return;
    await _service.play();
  }

  @override
  Future<void> loadQueueAndPlay({
    required List<AudioQueueItem> queue,
    required int initialIndex,
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
  }) async {
    if (queue.isEmpty) return;
    final background = _background;
    if (background == null) {
      final item = queue[initialIndex];
      return loadAndPlay(item.url, item.metadata);
    }
    final token = ++_loadToken;
    // The previous song must not keep playing while the new one loads.
    await _service.pause();
    if (token != _loadToken) return;
    await background.loadQueue(queue, initialIndex: initialIndex);
    if (token != _loadToken) return;
    await background.setRepeatMode(repeatMode);
    if (token != _loadToken) return;
    await background.setShuffleEnabled(shuffleEnabled);
    if (token != _loadToken) return;
    await _service.play();
  }

  @override
  Future<void> setShuffleEnabled(bool enabled) async =>
      _background?.setShuffleEnabled(enabled);

  @override
  Future<void> setRepeatMode(RepeatMode mode) async => _background?.setRepeatMode(mode);

  @override
  Future<void> pause() => _service.pause();

  @override
  Future<void> resume() => _service.play();

  @override
  Future<void> seek(Duration position) => _service.seek(position);

  @override
  Future<void> stop() => _service.stop();
}
