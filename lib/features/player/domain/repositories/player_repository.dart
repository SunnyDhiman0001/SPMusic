import '../entities/playback_status.dart';
import '../../data/services/audio_player_service.dart' show TrackMetadata;

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
