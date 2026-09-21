import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/library/presentation/bloc/library_cubit.dart';
import 'package:spmusic/features/library/presentation/bloc/library_state.dart';
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
  artworkUrl: 'https://picsum.photos/seed/album1/400',
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  duration: Duration(minutes: 3, seconds: 24),
);

const _song2 = SongEntity(
  id: 's2',
  title: 'Second Song',
  artist: 'Nova Wave',
  artistId: 'ar1',
  album: 'Neon Horizon',
  albumId: 'al1',
  artworkUrl: 'https://picsum.photos/seed/album1/400',
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  duration: Duration(minutes: 2, seconds: 10),
);

const _playlist = PlaylistEntity(
  id: 'p1',
  name: 'Chill Vibes',
  description: 'Relax',
  coverUrl: 'https://picsum.photos/seed/playlist1/400',
  songIds: ['s1', 's2'],
  creator: 'sunny',
);

const _album = AlbumEntity(
  id: 'al1',
  title: 'Neon Horizon',
  artistId: 'ar1',
  artistName: 'Nova Wave',
  coverUrl: 'https://picsum.photos/seed/album1/400',
  songIds: ['s1', 's2'],
);

const _artist = ArtistEntity(
  id: 'ar1',
  name: 'Nova Wave',
  imageUrl: 'https://picsum.photos/seed/artist1/400',
);

class _FakeMusicRepository implements MusicRepository {
  bool shouldThrow = false;

  @override
  Future<List<PlaylistEntity>> getAllPlaylists() async {
    if (shouldThrow) throw Exception('boom');
    return [_playlist];
  }

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    if (shouldThrow) throw Exception('boom');
    return [_album];
  }

  @override
  Future<List<ArtistEntity>> getAllArtists() async {
    if (shouldThrow) throw Exception('boom');
    return [_artist];
  }

  @override
  Future<List<SongEntity>> getFavoriteSongs() async {
    if (shouldThrow) throw Exception('boom');
    return [_song1];
  }

  @override
  Future<List<SongEntity>> getAllSongs() async {
    if (shouldThrow) throw Exception('boom');
    return [_song1, _song2];
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
  Future<void> toggleFavorite(String songId) => throw UnimplementedError();
}

void main() {
  late _FakeMusicRepository repository;

  setUp(() {
    repository = _FakeMusicRepository();
  });

  blocTest<LibraryCubit, LibraryState>(
    'emits [LibraryLoading, LibraryLoaded] with correct lists and default filter',
    build: () => LibraryCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<LibraryLoading>(),
      isA<LibraryLoaded>()
          .having((s) => s.filter, 'filter', LibraryFilter.all)
          .having((s) => s.playlists, 'playlists', [_playlist])
          .having((s) => s.albums, 'albums', [_album])
          .having((s) => s.artists, 'artists', [_artist])
          .having((s) => s.likedSongs, 'likedSongs', [_song1])
          .having((s) => s.recentlyPlayed, 'recentlyPlayed', [_song1, _song2]),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'emits [LibraryLoading, LibraryError] when the repository throws',
    build: () => LibraryCubit(repository),
    setUp: () => repository.shouldThrow = true,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<LibraryLoading>(),
      isA<LibraryError>(),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'setFilter on an already-loaded state updates only the filter field',
    build: () => LibraryCubit(repository),
    act: (cubit) async {
      await cubit.load();
      cubit.setFilter(LibraryFilter.songs);
    },
    expect: () => [
      isA<LibraryLoading>(),
      isA<LibraryLoaded>().having((s) => s.filter, 'filter', LibraryFilter.all),
      isA<LibraryLoaded>()
          .having((s) => s.filter, 'filter', LibraryFilter.songs)
          .having((s) => s.playlists, 'playlists', [_playlist])
          .having((s) => s.albums, 'albums', [_album])
          .having((s) => s.artists, 'artists', [_artist])
          .having((s) => s.likedSongs, 'likedSongs', [_song1])
          .having((s) => s.recentlyPlayed, 'recentlyPlayed', [_song1, _song2]),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'setFilter called before load() is a no-op',
    build: () => LibraryCubit(repository),
    act: (cubit) => cubit.setFilter(LibraryFilter.albums),
    expect: () => [],
    verify: (cubit) => expect(cubit.state, isA<LibraryLoading>()),
  );
}
