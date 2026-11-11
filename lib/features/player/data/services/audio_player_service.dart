import '../../domain/entities/playback_status.dart';
import '../../domain/entities/repeat_mode.dart';

class TrackMetadata {
  const TrackMetadata({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.artUri,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Uri? artUri;
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
