import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/player/data/services/audio_player_service.dart' show TrackMetadata;
import 'package:spmusic/features/player/domain/entities/playback_status.dart';
import 'package:spmusic/features/player/domain/repositories/player_repository.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';
import 'package:spmusic/features/player/presentation/widgets/mini_player.dart';

class FakePlayerRepository implements PlayerRepository {
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
  Future<void> loadAndPlay(String url, TrackMetadata metadata) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {}

  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _statusController.close();
  }
}

const testSong = SongEntity(
  id: '1',
  title: 'Song A',
  artist: 'Artist A',
  artistId: 'a1',
  album: 'Album A',
  albumId: 'al1',
  artworkId: 1,
  audioUrl: 'https://example.com/a.mp3',
  duration: Duration(minutes: 3),
);

Widget _wrap(PlayerCubit cubit) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MiniPlayer()),
      GoRoute(path: '/player', builder: (context, state) => const Scaffold(body: Text('Player'))),
    ],
  );
  return BlocProvider<PlayerCubit>.value(
    value: cubit,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late FakePlayerRepository fakeRepository;
  late PlayerCubit cubit;

  setUp(() {
    fakeRepository = FakePlayerRepository();
    cubit = PlayerCubit(fakeRepository);
  });

  tearDown(() async {
    await cubit.close();
    await fakeRepository.dispose();
  });

  testWidgets('renders nothing when there is no current song', (tester) async {
    await tester.pumpWidget(_wrap(cubit));

    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
    expect(find.text(testSong.title), findsNothing);
  });

  testWidgets('renders title, artist and play icon once a song is loaded', (tester) async {
    await tester.pumpWidget(_wrap(cubit));

    // NotificationArtwork does real file I/O, which needs the real async zone.
    await tester.runAsync(() => cubit.playSingle(testSong));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(testSong.title), findsOneWidget);
    expect(find.text(testSong.artist), findsOneWidget);
    expect(find.byIcon(LucideIcons.play), findsOneWidget);
  });
}
