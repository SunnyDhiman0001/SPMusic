import '../entities/playback_status.dart';
import '../entities/repeat_mode.dart';
import '../../data/services/audio_player_service.dart' show AudioQueueItem, TrackMetadata;

abstract class PlayerRepository {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlaybackStatus> get statusStream;

  Future<void> loadAndPlay(String url, TrackMetadata metadata);
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> stop();
}

/// Queue and remote-control capabilities exposed by background capable
/// repositories while preserving the small core player contract.
abstract interface class BackgroundPlayerRepository {
  Stream<int?> get currentIndexStream;
  Future<void> loadQueueAndPlay({
    required List<AudioQueueItem> queue,
    required int initialIndex,
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
  });
  Future<void> setShuffleEnabled(bool enabled);
  Future<void> setRepeatMode(RepeatMode mode);
}

extension BackgroundPlayerRepositoryOperations on PlayerRepository {
  BackgroundPlayerRepository? get _background {
    final repository = this;
    return repository is BackgroundPlayerRepository
        ? repository as BackgroundPlayerRepository
        : null;
  }

  Stream<int?> get currentIndexStream =>
      _background?.currentIndexStream ?? const Stream<int?>.empty();

  Future<void> loadQueueAndPlay({
    required List<AudioQueueItem> queue,
    required int initialIndex,
    required bool shuffleEnabled,
    required RepeatMode repeatMode,
  }) async {
    if (queue.isEmpty) return;
    final background = _background;
    if (background != null) {
      return background.loadQueueAndPlay(
        queue: queue,
        initialIndex: initialIndex,
        shuffleEnabled: shuffleEnabled,
        repeatMode: repeatMode,
      );
    }
    final item = queue[initialIndex];
    return loadAndPlay(item.url, item.metadata);
  }

  Future<void> setShuffleEnabled(bool enabled) async =>
      _background?.setShuffleEnabled(enabled);

  Future<void> setRepeatMode(RepeatMode mode) async => _background?.setRepeatMode(mode);
}
