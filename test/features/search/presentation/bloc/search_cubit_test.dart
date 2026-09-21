import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/music/domain/entities/album_entity.dart';
import 'package:spmusic/features/music/domain/entities/artist_entity.dart';
import 'package:spmusic/features/music/domain/entities/playlist_entity.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/music/domain/repositories/music_repository.dart';
import 'package:spmusic/features/search/presentation/bloc/search_cubit.dart';
import 'package:spmusic/features/search/presentation/bloc/search_state.dart';

const _song = SongEntity(
  id: 's1',
  title: 'Midnight Drive',
  artist: 'Nova Wave',
  artistId: 'ar1',
  album: 'Neon Horizon',
  albumId: 'al1',
  artworkUrl: 'https://picsum.photos/seed/album1/400',
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  duration: Duration(minutes: 3, seconds: 24),
);

const _artist = ArtistEntity(
  id: 'ar1',
  name: 'Nova Wave',
  imageUrl: 'https://picsum.photos/seed/artist1/400',
);

class _FakeMusicRepository implements MusicRepository {
  bool shouldThrow = false;

  @override
  Future<List<SongEntity>> searchSongs(String query) async {
    if (shouldThrow) throw Exception('boom');
    return query.toLowerCase().contains('midnight') ? [_song] : [];
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String query) async {
    if (shouldThrow) throw Exception('boom');
    return query.toLowerCase().contains('nova') ? [_artist] : [];
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String query) async {
    if (shouldThrow) throw Exception('boom');
    return [];
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String query) async {
    if (shouldThrow) throw Exception('boom');
    return [];
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
  Future<List<SongEntity>> getFavoriteSongs() => throw UnimplementedError();

  @override
  Future<void> toggleFavorite(String songId) => throw UnimplementedError();
}

void main() {
  late _FakeMusicRepository repository;

  setUp(() {
    repository = _FakeMusicRepository();
  });

  blocTest<SearchCubit, SearchState>(
    'emits SearchIdle when query is empty',
    build: () => SearchCubit(repository),
    act: (cubit) => cubit.search('   '),
    expect: () => [isA<SearchIdle>()],
  );

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchLoaded] with matching results and updates recentSearches',
    build: () => SearchCubit(repository),
    act: (cubit) => cubit.search('Midnight'),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchLoaded>()
          .having((s) => s.results.songs.single.id, 'song id', 's1')
          .having((s) => s.results.artists, 'artists', isEmpty)
          .having((s) => s.recentSearches, 'recentSearches', ['Midnight']),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchError] when the repository throws',
    build: () => SearchCubit(repository),
    setUp: () => repository.shouldThrow = true,
    act: (cubit) => cubit.search('Midnight'),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchError>(),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'keeps both queries in recentSearches with most recent first',
    build: () => SearchCubit(repository),
    act: (cubit) async {
      await cubit.search('Midnight');
      await cubit.search('Nova');
    },
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchLoaded>().having((s) => s.recentSearches, 'recentSearches', ['Midnight']),
      isA<SearchLoading>(),
      isA<SearchLoaded>().having((s) => s.recentSearches, 'recentSearches', ['Nova', 'Midnight']),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'does not duplicate the same query searched twice (case-insensitive)',
    build: () => SearchCubit(repository),
    act: (cubit) async {
      await cubit.search('Midnight');
      await cubit.search('midnight');
    },
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchLoaded>().having((s) => s.recentSearches, 'recentSearches', ['Midnight']),
      isA<SearchLoading>(),
      isA<SearchLoaded>().having((s) => s.recentSearches, 'recentSearches', ['midnight']),
    ],
  );
}
