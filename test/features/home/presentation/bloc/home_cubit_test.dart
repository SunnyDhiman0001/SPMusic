import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/home/presentation/bloc/home_cubit.dart';
import 'package:spmusic/features/home/presentation/bloc/home_state.dart';
import 'package:spmusic/features/music/domain/entities/album_entity.dart';
import 'package:spmusic/features/music/domain/entities/artist_entity.dart';
import 'package:spmusic/features/music/domain/entities/playlist_entity.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/music/domain/repositories/music_repository.dart';

const _song = SongEntity(
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

const _playlist = PlaylistEntity(
  id: 'p1',
  name: 'Focus Flow',
  description: 'Steady beats.',
  songIds: ['s1'],
  creator: 'spmusic',
);

const _artist = ArtistEntity(
  id: 'ar1',
  name: 'Nova Wave',
  trackCount: 12,
);

class _FakeMusicRepository implements MusicRepository {
  bool shouldThrow = false;

  @override
  Future<List<SongEntity>> getRecentlyPlayed() async {
    if (shouldThrow) throw Exception('boom');
    return [_song];
  }

  @override
  Future<List<PlaylistEntity>> getMadeForYouPlaylists() async => [_playlist];

  @override
  Future<List<SongEntity>> getTrendingSongs() async => [_song];

  @override
  Future<List<ArtistEntity>> getPopularArtists() async => [_artist];

  @override
  Future<List<SongEntity>> getAllSongs() async => [_song];

  @override
  Future<List<ArtistEntity>> getAllArtists() async => [_artist];

  @override
  Future<List<AlbumEntity>> getAllAlbums() async => [];

  @override
  Future<List<PlaylistEntity>> getAllPlaylists() async => [_playlist];

  @override
  Future<PlaylistEntity> getPlaylistById(String id) async => _playlist;

  @override
  Future<List<SongEntity>> getSongsByIds(List<String> ids) async => [_song];

  @override
  Future<List<SongEntity>> searchSongs(String query) async => [_song];

  @override
  Future<List<ArtistEntity>> searchArtists(String query) async => [_artist];

  @override
  Future<List<AlbumEntity>> searchAlbums(String query) async => [];

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String query) async => [_playlist];

  @override
  Future<List<SongEntity>> getFavoriteSongs() async => [];

  @override
  Future<void> toggleFavorite(String songId) async {}

  @override
  Future<void> recordPlayed(String songId) async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  late _FakeMusicRepository repository;

  setUp(() {
    repository = _FakeMusicRepository();
  });

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeLoaded] with correctly-mapped CardDisplayItems on success',
    build: () => HomeCubit(repository),
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const HomeLoading(),
      isA<HomeLoaded>()
          .having((s) => s.recentlyPlayed.single.id, 'recentlyPlayed id', 's1')
          .having((s) => s.recentlyPlayed.single.title, 'recentlyPlayed title', 'Midnight Drive')
          .having((s) => s.recentlyPlayed.single.subtitle, 'recentlyPlayed subtitle', 'Nova Wave')
          .having((s) => s.madeForYou.single.title, 'madeForYou title', 'Focus Flow')
          .having((s) => s.trending.single.id, 'trending id', 's1')
          .having((s) => s.popularArtists.single.title, 'popularArtists title', 'Nova Wave')
          .having((s) => s.popularArtists.single.subtitle, 'popularArtists subtitle', '12 tracks'),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeError] when the repository throws',
    build: () => HomeCubit(repository),
    setUp: () => repository.shouldThrow = true,
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const HomeLoading(),
      isA<HomeError>(),
    ],
  );
}
