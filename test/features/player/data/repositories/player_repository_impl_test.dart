import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/player/data/repositories/player_repository_impl.dart';
import 'package:spmusic/features/player/data/services/audio_player_service.dart';
import 'package:spmusic/features/player/domain/entities/playback_status.dart';

class FakeAudioPlayerService implements AudioPlayerService {
  final List<String> loadedUrls = [];
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  final List<Duration> seekedPositions = [];

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _statusController = StreamController<PlaybackStatus>.broadcast();

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<PlaybackStatus> get statusStream => _statusController.stream;

  @override
  Future<void> load(String url) async {
    loadedUrls.add(url);
  }

  @override
  Future<void> play() async {
    playCalls++;
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> seek(Duration position) async {
    seekedPositions.add(position);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeAudioPlayerService fakeService;
  late PlayerRepositoryImpl repository;

  setUp(() {
    fakeService = FakeAudioPlayerService();
    repository = PlayerRepositoryImpl(fakeService);
  });

  group('PlayerRepositoryImpl', () {
    test('loadAndPlay calls load then play with the right url', () async {
      await repository.loadAndPlay('https://example.com/song.mp3');

      expect(fakeService.loadedUrls, ['https://example.com/song.mp3']);
      expect(fakeService.playCalls, 1);
    });

    test('pause delegates to service pause', () async {
      await repository.pause();

      expect(fakeService.pauseCalls, 1);
    });

    test('resume delegates to service play', () async {
      await repository.resume();

      expect(fakeService.playCalls, 1);
    });

    test('seek delegates to service seek with the right position', () async {
      await repository.seek(const Duration(seconds: 42));

      expect(fakeService.seekedPositions, [const Duration(seconds: 42)]);
    });

    test('stop delegates to service stop', () async {
      await repository.stop();

      expect(fakeService.stopCalls, 1);
    });

    test('positionStream passes through unchanged', () async {
      final future = repository.positionStream.first;
      fakeService._positionController.add(const Duration(seconds: 5));

      expect(await future, const Duration(seconds: 5));
    });

    test('durationStream passes through unchanged', () async {
      final future = repository.durationStream.first;
      fakeService._durationController.add(const Duration(minutes: 3));

      expect(await future, const Duration(minutes: 3));
    });

    test('statusStream passes through unchanged', () async {
      final future = repository.statusStream.first;
      fakeService._statusController.add(PlaybackStatus.playing);

      expect(await future, PlaybackStatus.playing);
    });
  });
}
