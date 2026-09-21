import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/home/presentation/bloc/home_cubit.dart';
import 'package:spmusic/features/home/presentation/bloc/home_state.dart';
import 'package:spmusic/features/music/data/services/music_permission_service.dart';
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
  audioUrl: 'content://media/external/audio/media/1',
  duration: Duration(minutes: 3, seconds: 24),
);

class _FakeMusicRepository implements MusicRepository {
  bool shouldThrow = false;
  List<SongEntity> songs = [_song];

  @override
  Future<List<SongEntity>> getRecentlyPlayed() async => songs;

  @override
  Future<List<PlaylistEntity>> getMadeForYouPlaylists() async => [];

  @override
  Future<List<SongEntity>> getTrendingSongs() async => songs;

  @override
  Future<List<ArtistEntity>> getPopularArtists() async => [];

  @override
  Future<List<SongEntity>> getAllSongs() async {
    if (shouldThrow) throw Exception('boom');
    return songs;
  }

  @override
  Future<List<ArtistEntity>> getAllArtists() async => [];

  @override
  Future<List<AlbumEntity>> getAllAlbums() async => [];

  @override
  Future<List<PlaylistEntity>> getAllPlaylists() async => [];

  @override
  Future<PlaylistEntity> getPlaylistById(String id) async =>
      throw StateError('not found');

  @override
  Future<List<SongEntity>> getSongsByIds(List<String> ids) async => songs;

  @override
  Future<List<SongEntity>> searchSongs(String query) async => songs;

  @override
  Future<List<ArtistEntity>> searchArtists(String query) async => [];

  @override
  Future<List<AlbumEntity>> searchAlbums(String query) async => [];

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String query) async => [];

  @override
  Future<List<SongEntity>> getFavoriteSongs() async => [];

  @override
  Future<void> toggleFavorite(String songId) async {}

  @override
  Future<void> recordPlayed(String songId) async {}

  @override
  Future<void> refresh() async {}
}

class _FakeMusicPermissionService implements MusicPermissionService {
  MusicPermissionStatus status = MusicPermissionStatus.granted;

  @override
  Future<MusicPermissionStatus> check() async => status;

  @override
  Future<MusicPermissionStatus> request() async => status;

  @override
  Future<void> openSettings() async {}
}

void main() {
  late _FakeMusicRepository repository;
  late _FakeMusicPermissionService permissionService;

  setUp(() {
    repository = _FakeMusicRepository();
    permissionService = _FakeMusicPermissionService();
  });

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeLoaded] with the device songs on success',
    build: () => HomeCubit(repository, permissionService),
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const HomeLoading(),
      isA<HomeLoaded>()
          .having((s) => s.songs.single.id, 'songs id', 's1')
          .having((s) => s.songs.single.title, 'songs title', 'Midnight Drive')
          .having((s) => s.isEmpty, 'isEmpty', false),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeLoaded] with isEmpty when there are no songs',
    build: () => HomeCubit(repository, permissionService),
    setUp: () => repository.songs = [],
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const HomeLoading(),
      isA<HomeLoaded>().having((s) => s.isEmpty, 'isEmpty', true),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [HomeLoading, HomeError] when the repository throws',
    build: () => HomeCubit(repository, permissionService),
    setUp: () => repository.shouldThrow = true,
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const HomeLoading(),
      isA<HomeError>(),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'emits HomePermissionDenied when permission is not granted',
    build: () => HomeCubit(repository, permissionService),
    setUp: () => permissionService.status = MusicPermissionStatus.denied,
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const HomeLoading(),
      const HomePermissionDenied(permanentlyDenied: false),
    ],
  );
}
