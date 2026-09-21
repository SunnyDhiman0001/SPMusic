import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/favorites/presentation/bloc/favorites_cubit.dart';
import 'package:spmusic/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:spmusic/features/music/domain/entities/album_entity.dart';
import 'package:spmusic/features/music/domain/entities/artist_entity.dart';
import 'package:spmusic/features/music/domain/entities/playlist_entity.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/music/domain/repositories/music_repository.dart';

const _song1 = SongEntity(
  id: 's1',
  title: 'Midnight Drive',
  artist: 'Nova Wave',
  artistId: 'ar1',
  album: 'Neon Horizon',
  albumId: 'al1',
  artworkId: 1,
  audioUrl: 'content://media/external/audio/media/1',
  duration: Duration(minutes: 3, seconds: 24),
  isFavorite: true,
);

const _song2 = SongEntity(
  id: 's2',
  title: 'Golden Hour',
  artist: 'Aria Storm',
  artistId: 'ar2',
  album: 'Golden Static',
  albumId: 'al2',
  artworkId: 2,
  audioUrl: 'content://media/external/audio/media/2',
  duration: Duration(minutes: 3, seconds: 12),
  isFavorite: true,
);

class _FakeMusicRepository implements MusicRepository {
  List<SongEntity> favoriteSongs = [_song1, _song2];
  bool shouldThrow = false;
  final List<String> toggledSongIds = [];

  @override
  Future<List<SongEntity>> getFavoriteSongs() async {
    if (shouldThrow) throw Exception('boom');
    return favoriteSongs;
  }

  @override
  Future<void> toggleFavorite(String songId) async {
    toggledSongIds.add(songId);
    final isCurrentlyFavorite = favoriteSongs.any((song) => song.id == songId);
    favoriteSongs = isCurrentlyFavorite
        ? favoriteSongs.where((song) => song.id != songId).toList()
        : favoriteSongs;
  }

  @override
  Future<List<SongEntity>> getRecentlyPlayed() => throw UnimplementedError();

  @override
  Future<List<PlaylistEntity>> getMadeForYouPlaylists() => throw UnimplementedError();

  @override
  Future<List<SongEntity>> getTrendingSongs() => throw UnimplementedError();

  @override
  Future<List<ArtistEntity>> getPopularArtists() => throw UnimplementedError();

  @override
  Future<List<SongEntity>> getAllSongs() => throw UnimplementedError();

  @override
  Future<List<ArtistEntity>> getAllArtists() => throw UnimplementedError();

  @override
  Future<List<AlbumEntity>> getAllAlbums() => throw UnimplementedError();

  @override
  Future<List<PlaylistEntity>> getAllPlaylists() => throw UnimplementedError();

  @override
  Future<PlaylistEntity> getPlaylistById(String id) => throw UnimplementedError();

  @override
  Future<List<SongEntity>> getSongsByIds(List<String> ids) => throw UnimplementedError();

  @override
  Future<List<SongEntity>> searchSongs(String query) => throw UnimplementedError();

  @override
  Future<List<ArtistEntity>> searchArtists(String query) => throw UnimplementedError();

  @override
  Future<List<AlbumEntity>> searchAlbums(String query) => throw UnimplementedError();

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String query) => throw UnimplementedError();

  @override
  Future<void> recordPlayed(String songId) => throw UnimplementedError();

  @override
  Future<void> refresh() => throw UnimplementedError();
}

void main() {
  late _FakeMusicRepository repository;

  setUp(() {
    repository = _FakeMusicRepository();
  });

  blocTest<FavoritesCubit, FavoritesState>(
    'load emits [FavoritesLoading, FavoritesLoaded] with the favorite songs and their ids',
    build: () => FavoritesCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<FavoritesLoading>(),
      isA<FavoritesLoaded>()
          .having((s) => s.songs, 'songs', [_song1, _song2])
          .having((s) => s.favoriteSongIds, 'favoriteSongIds', {'s1', 's2'}),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'load emits [FavoritesLoading, FavoritesError] when the repository throws',
    build: () => FavoritesCubit(repository),
    setUp: () => repository.shouldThrow = true,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<FavoritesLoading>(),
      isA<FavoritesError>(),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggleFavorite removes an unfavorited song from the loaded list immediately',
    build: () => FavoritesCubit(repository),
    act: (cubit) async {
      await cubit.load();
      await cubit.toggleFavorite('s1');
    },
    expect: () => [
      isA<FavoritesLoading>(),
      isA<FavoritesLoaded>().having((s) => s.favoriteSongIds, 'favoriteSongIds', {'s1', 's2'}),
      isA<FavoritesLoading>(),
      isA<FavoritesLoaded>()
          .having((s) => s.songs, 'songs', [_song2])
          .having((s) => s.favoriteSongIds, 'favoriteSongIds', {'s2'}),
    ],
    verify: (_) {
      expect(repository.toggledSongIds, ['s1']);
    },
  );

  test('isFavorite reflects the current loaded state, false before loading', () async {
    final cubit = FavoritesCubit(repository);
    expect(cubit.isFavorite('s1'), isFalse);

    await cubit.load();
    expect(cubit.isFavorite('s1'), isTrue);
    expect(cubit.isFavorite('unknown'), isFalse);

    await cubit.close();
  });
}
