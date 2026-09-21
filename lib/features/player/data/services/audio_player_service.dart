import '../../domain/entities/playback_status.dart';

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
