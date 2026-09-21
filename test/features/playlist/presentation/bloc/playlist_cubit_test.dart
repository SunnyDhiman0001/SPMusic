import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/music/domain/entities/album_entity.dart';
import 'package:spmusic/features/music/domain/entities/artist_entity.dart';
import 'package:spmusic/features/music/domain/entities/playlist_entity.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/music/domain/repositories/music_repository.dart';
import 'package:spmusic/features/playlist/presentation/bloc/playlist_cubit.dart';
import 'package:spmusic/features/playlist/presentation/bloc/playlist_state.dart';

const _song1 = SongEntity(
  id: 's1',
  title: 'Midnight Drive',
  artist: 'Nova Wave',
  artistId: 'ar1',
  album: 'Neon Horizon',
  albumId: 'al1',
  artworkId: 1,
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
  artworkId: 1,
  audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  duration: Duration(minutes: 2, seconds: 10),
);

const _playlist = PlaylistEntity(
  id: 'p1',
  name: 'Chill Vibes',
  description: 'Relax',
  songIds: ['s1', 's2'],
  creator: 'sunny',
);

class _FakeMusicRepository implements MusicRepository {
  @override
  Future<PlaylistEntity> getPlaylistById(String id) async {
    if (id != 'p1') throw StateError('Playlist not found: $id');
    return _playlist;
  }

  @override
  Future<List<SongEntity>> getSongsByIds(List<String> ids) async => [_song1, _song2];

  @override
  Future<void> toggleFavorite(String songId) => throw UnimplementedError();

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
  Future<List<SongEntity>> searchSongs(String query) => throw UnimplementedError();

  @override
  Future<List<ArtistEntity>> searchArtists(String query) => throw UnimplementedError();

  @override
  Future<List<AlbumEntity>> searchAlbums(String query) => throw UnimplementedError();

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String query) => throw UnimplementedError();

  @override
  Future<List<SongEntity>> getFavoriteSongs() => throw UnimplementedError();

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

  blocTest<PlaylistCubit, PlaylistState>(
    'loadPlaylist emits [PlaylistLoading, PlaylistLoaded] with correct data',
    build: () => PlaylistCubit(repository),
    act: (cubit) => cubit.loadPlaylist('p1'),
    expect: () => [
      isA<PlaylistLoading>(),
      isA<PlaylistLoaded>()
          .having((s) => s.playlist, 'playlist', _playlist)
          .having((s) => s.songs, 'songs', [_song1, _song2]),
    ],
  );

  blocTest<PlaylistCubit, PlaylistState>(
    'loadPlaylist emits [PlaylistLoading, PlaylistError] when playlist is missing',
    build: () => PlaylistCubit(repository),
    act: (cubit) => cubit.loadPlaylist('missing'),
    expect: () => [
      isA<PlaylistLoading>(),
      isA<PlaylistError>(),
    ],
  );
}
