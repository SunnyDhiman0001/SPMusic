import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/home/presentation/bloc/recently_played_cubit.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/music/domain/repositories/music_repository.dart';

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

/// Mimics the real repository: ids stored newest-first and de-duplicated.
class _FakeRepository implements MusicRepository {
  _FakeRepository(this.library);

  final List<SongEntity> library;
  List<String> ids = [];
  bool throwOnLoad = false;

  @override
  Future<List<SongEntity>> getRecentlyPlayed() async {
    if (throwOnLoad) throw Exception('boom');
    return [for (final id in ids) library.firstWhere((s) => s.id == id)];
  }

  @override
  Future<void> recordPlayed(String songId) async {
    ids = [songId, ...ids.where((id) => id != songId)];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final library = [for (var i = 1; i <= 15; i++) _song(i)];
  late _FakeRepository repository;
  late RecentlyPlayedCubit cubit;

  setUp(() {
    repository = _FakeRepository(library);
    cubit = RecentlyPlayedCubit(repository);
  });

  tearDown(() => cubit.close());

  test('starts empty', () {
    expect(cubit.state, isEmpty);
  });

  test('load keeps at most 10 songs, newest first', () async {
    repository.ids = [for (var i = 15; i >= 1; i--) 's$i'];

    await cubit.load();

    expect(cubit.state.length, 10);
    expect(cubit.state.first.id, 's15');
    expect(cubit.state.last.id, 's6');
  });

  test('onSongStarted records the song and moves it to the front', () async {
    repository.ids = ['s1', 's2'];
    await cubit.load();

    await cubit.onSongStarted('s2');

    expect(cubit.state.map((s) => s.id), ['s2', 's1']);
  });

  test('a repeated song appears once', () async {
    await cubit.onSongStarted('s1');
    await cubit.onSongStarted('s2');
    await cubit.onSongStarted('s1');

    expect(cubit.state.map((s) => s.id), ['s1', 's2']);
  });

  test('a failing load keeps the last good list', () async {
    await cubit.onSongStarted('s1');
    repository.throwOnLoad = true;

    await cubit.load();

    expect(cubit.state.map((s) => s.id), ['s1']);
  });

  test('reloads when the library changes', () async {
    final changes = StreamController<void>.broadcast();
    final reactive = RecentlyPlayedCubit(repository, libraryChanges: changes.stream);
    repository.ids = ['s3'];

    changes.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(reactive.state.map((s) => s.id), ['s3']);
    await reactive.close();
    await changes.close();
  });
}
