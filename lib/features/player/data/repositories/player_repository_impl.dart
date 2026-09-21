import '../../domain/entities/playback_status.dart';
import '../../domain/repositories/player_repository.dart';
import '../services/audio_player_service.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl(this._service);

  final AudioPlayerService _service;

  @override
  Stream<Duration> get positionStream => _service.positionStream;

  @override
  Stream<Duration?> get durationStream => _service.durationStream;

  @override
  Stream<PlaybackStatus> get statusStream => _service.statusStream;

  @override
  Future<void> loadAndPlay(String url) async {
    await _service.load(url);
    await _service.play();
  }

  @override
  Future<void> pause() => _service.pause();

  @override
  Future<void> resume() => _service.play();

  @override
  Future<void> seek(Duration position) => _service.seek(position);

  @override
  Future<void> stop() => _service.stop();
}
