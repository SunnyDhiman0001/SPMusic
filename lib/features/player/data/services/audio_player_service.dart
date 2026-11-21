import '../../domain/entities/playback_status.dart';
import '../../domain/entities/repeat_mode.dart';

class TrackMetadata {
  const TrackMetadata({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.artUri,
    this.duration,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Uri? artUri;
  final Duration? duration;
}

class AudioQueueItem {
  const AudioQueueItem({required this.url, required this.metadata});

  final String url;
  final TrackMetadata metadata;
}

abstract class AudioPlayerService {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlaybackStatus> get statusStream;

  Future<void> load(String url, TrackMetadata metadata);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> dispose();
}

/// Extra queue controls used by the background media session. Kept separate
/// from [AudioPlayerService] so simple test or alternate players need not
/// implement queue behavior they do not support.
abstract interface class BackgroundAudioPlayerService {
  Stream<int?> get currentIndexStream;
  Future<void> loadQueue(List<AudioQueueItem> queue, {required int initialIndex});
  Future<void> setShuffleEnabled(bool enabled);
  Future<void> setRepeatMode(RepeatMode mode);
}

/// Actions the system media notification / lock screen can trigger. The
/// player cubit owns queue, shuffle and favourites, so the media session
/// delegates to it instead of keeping a second copy of that logic.
abstract interface class MediaSessionDelegate {
  Future<void> onSkipNext();
  Future<void> onSkipPrevious();
  Future<void> onToggleFavorite();
  Future<void> onToggleShuffle();
}

/// Owns the single system media session (notification + lock screen).
abstract interface class MediaSessionService {
  Future<void> initMediaSession(MediaSessionDelegate delegate);

  /// Updates the like / shuffle buttons shown on the media notification.
  void updateSession({required bool isShuffle, required bool isFavorite});
}
