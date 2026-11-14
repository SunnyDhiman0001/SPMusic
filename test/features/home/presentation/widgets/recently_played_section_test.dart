import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/home/presentation/bloc/recently_played_cubit.dart';
import 'package:spmusic/features/home/presentation/widgets/recently_played_section.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/music/domain/repositories/music_repository.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';

import '../../../player/presentation/bloc/player_cubit_test.dart' show FakePlayerRepository;

SongEntity _song(int i) => SongEntity(
      id: 's$i',
      title: 'Song $i',
      artist: 'Artist',
      artistId: 'a',
      album: 'Album',
      albumId: 'al',
      artworkId: i,
      audioUrl: 'content://media/$i',
      duration: const Duration(minutes: 3),
    );

class _FakeRepository implements MusicRepository {
  _FakeRepository(this.songs);
  final List<SongEntity> songs;

  @override
  Future<List<SongEntity>> getRecentlyPlayed() async => songs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakePlayerRepository playerRepository;
  late PlayerCubit playerCubit;

  setUp(() {
    playerRepository = FakePlayerRepository();
    playerCubit = PlayerCubit(playerRepository);
  });

  tearDown(() async {
    await playerCubit.close();
    await playerRepository.dispose();
  });

  Future<RecentlyPlayedCubit> pumpSection(WidgetTester tester, List<SongEntity> songs) async {
    final cubit = RecentlyPlayedCubit(_FakeRepository(songs));
    await tester.runAsync(cubit.load);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<RecentlyPlayedCubit>.value(value: cubit),
          BlocProvider<PlayerCubit>.value(value: playerCubit),
        ],
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(body: SingleChildScrollView(child: RecentlyPlayedSection())),
        ),
      ),
    );
    // Let the staggered entrance animation finish before the test asserts.
    await tester.pumpAndSettle();
    addTearDown(cubit.close);
    return cubit;
  }

  testWidgets('shows nothing when there is no history', (tester) async {
    await pumpSection(tester, const []);
    expect(find.text('Recently Played'), findsNothing);
  });

  testWidgets('shows the heading and one card per song, in order', (tester) async {
    await pumpSection(tester, [_song(3), _song(2), _song(1)]);

    expect(find.text('Recently Played'), findsOneWidget);
    expect(find.byKey(const ValueKey('recent-s3')), findsOneWidget);
    expect(find.byKey(const ValueKey('recent-s2')), findsOneWidget);
    expect(find.byKey(const ValueKey('recent-s1')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('recent-s3'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('recent-s2'))).dx),
    );
  });

  testWidgets('tapping a card plays that song', (tester) async {
    await pumpSection(tester, [_song(3), _song(2)]);

    // Starting playback does real file I/O and a real-time timeout (the
    // notification artwork lookup), so the tap itself must run in the real zone.
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('recent-s2')));
      await Future<void>.delayed(const Duration(milliseconds: 900));
    });

    expect(playerRepository.loadedUrls, ['content://media/2']);
  });
}
