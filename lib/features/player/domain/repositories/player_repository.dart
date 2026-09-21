import '../entities/playback_status.dart';

abstract class PlayerRepository {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlaybackStatus> get statusStream;

  Future<void> loadAndPlay(String url);
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> stop();
}
