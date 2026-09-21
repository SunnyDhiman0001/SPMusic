import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/player/domain/entities/playback_status.dart';
import 'package:spmusic/features/player/domain/entities/repeat_mode.dart';
import 'package:spmusic/features/player/domain/repositories/player_repository.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';
import 'package:spmusic/features/player/presentation/bloc/player_state.dart';

class FakePlayerRepository implements PlayerRepository {
  final List<String> loadedUrls = [];
  final List<Duration> seekedPositions = [];
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;

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
  Future<void> loadAndPlay(String url) async {
    loadedUrls.add(url);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
  }

  @override
  Future<void> seek(Duration position) async {
    seekedPositions.add(position);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  void emitStatus(PlaybackStatus status) => _statusController.add(status);
  void emitPosition(Duration position) => _positionController.add(position);
  void emitDuration(Duration? duration) => _durationController.add(duration);

  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _statusController.close();
  }
}

const songA = SongEntity(
  id: '1',
  title: 'Song A',
  artist: 'Artist A',
  artistId: 'a1',
  album: 'Album A',
  albumId: 'al1',
  artworkUrl: 'art_a.png',
  audioUrl: 'https://example.com/a.mp3',
  duration: Duration(minutes: 3),
);

const songB = SongEntity(
  id: '2',
  title: 'Song B',
  artist: 'Artist B',
  artistId: 'b1',
  album: 'Album B',
  albumId: 'bl1',
  artworkUrl: 'art_b.png',
  audioUrl: 'https://example.com/b.mp3',
  duration: Duration(minutes: 4),
);

void main() {
  late FakePlayerRepository fakeRepository;

  setUp(() {
    fakeRepository = FakePlayerRepository();
  });

  tearDown(() async {
    await fakeRepository.dispose();
  });

  group('PlayerCubit', () {
    blocTest<PlayerCubit, PlayerState>(
      'playQueue with 2 songs starting at index 0 loads first song and sets currentIndex',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) => cubit.playQueue([songA, songB]),
      verify: (cubit) {
        expect(fakeRepository.loadedUrls, [songA.audioUrl]);
        expect(cubit.state.currentIndex, 0);
        expect(cubit.state.currentSong, songA);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'skipNext loads second song then wraps back to first on a 2-song queue',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) async {
        await cubit.playQueue([songA, songB]);
        await cubit.skipNext();
        await cubit.skipNext();
      },
      verify: (cubit) {
        expect(fakeRepository.loadedUrls, [
          songA.audioUrl,
          songB.audioUrl,
          songA.audioUrl,
        ]);
        expect(cubit.state.currentIndex, 0);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'completed status with repeatMode.one reloads the same song',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) async {
        await cubit.playQueue([songA, songB]);
        cubit.cycleRepeatMode(); // off -> all
        cubit.cycleRepeatMode(); // all -> one
        fakeRepository.emitStatus(PlaybackStatus.completed);
        await Future<void>.delayed(Duration.zero);
      },
      verify: (cubit) {
        expect(fakeRepository.loadedUrls, [songA.audioUrl, songA.audioUrl]);
        expect(cubit.state.currentIndex, 0);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'skipPrevious seeks to zero when position is large instead of changing track',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) async {
        await cubit.playQueue([songA, songB], startIndex: 1);
        fakeRepository.emitPosition(const Duration(seconds: 10));
        await Future<void>.delayed(Duration.zero);
        await cubit.skipPrevious();
      },
      verify: (cubit) {
        expect(fakeRepository.loadedUrls, [songB.audioUrl]);
        expect(fakeRepository.seekedPositions, [Duration.zero]);
        expect(cubit.state.currentIndex, 1);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'skipPrevious moves to previous track when position is small',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) async {
        await cubit.playQueue([songA, songB], startIndex: 1);
        await cubit.skipPrevious();
      },
      verify: (cubit) {
        expect(fakeRepository.loadedUrls, [songB.audioUrl, songA.audioUrl]);
        expect(cubit.state.currentIndex, 0);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'togglePlayPause pauses when playing and resumes when paused',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) async {
        await cubit.playQueue([songA]);
        fakeRepository.emitStatus(PlaybackStatus.playing);
        await Future<void>.delayed(Duration.zero);
        await cubit.togglePlayPause();
        fakeRepository.emitStatus(PlaybackStatus.paused);
        await Future<void>.delayed(Duration.zero);
        await cubit.togglePlayPause();
      },
      verify: (cubit) {
        expect(fakeRepository.pauseCalls, 1);
        expect(fakeRepository.resumeCalls, 1);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'toggleShuffle flips isShuffle flag',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) => cubit.toggleShuffle(),
      expect: () => [isA<PlayerState>().having((s) => s.isShuffle, 'isShuffle', true)],
    );

    blocTest<PlayerCubit, PlayerState>(
      'cycleRepeatMode goes off -> all -> one -> off',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) {
        cubit.cycleRepeatMode();
        cubit.cycleRepeatMode();
        cubit.cycleRepeatMode();
      },
      verify: (cubit) {
        expect(cubit.state.repeatMode, RepeatMode.off);
      },
    );

    blocTest<PlayerCubit, PlayerState>(
      'position and duration stream updates are reflected in state',
      build: () => PlayerCubit(fakeRepository),
      act: (cubit) async {
        fakeRepository.emitPosition(const Duration(seconds: 5));
        fakeRepository.emitDuration(const Duration(minutes: 3));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (cubit) {
        expect(cubit.state.position, const Duration(seconds: 5));
        expect(cubit.state.duration, const Duration(minutes: 3));
      },
    );
  });
}
