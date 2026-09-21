import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/music/data/datasources/local_music_data_source.dart';
import 'package:spmusic/features/music/data/models/album_model.dart';
import 'package:spmusic/features/music/data/models/artist_model.dart';
import 'package:spmusic/features/music/data/models/playlist_model.dart';
import 'package:spmusic/features/music/data/models/song_model.dart';
import 'package:spmusic/features/music/data/repositories/music_repository_impl.dart';
import 'package:spmusic/features/music/data/services/local_storage_service.dart';

class _FakeLocalMusicDataSource implements LocalMusicDataSource {
  static const _songs = [
    SongModel(
      id: 's1',
      title: 'Midnight Drive',
      artist: 'Nova Wave',
      artistId: 'ar1',
      album: 'Neon Horizon',
      albumId: 'al1',
      artworkId: 1,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      duration: Duration(minutes: 3, seconds: 24),
    ),
    SongModel(
      id: 's2',
      title: 'Golden Hour',
      artist: 'Aria Storm',
      artistId: 'ar2',
      album: 'Golden Static',
      albumId: 'al2',
      artworkId: 2,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      duration: Duration(minutes: 3, seconds: 12),
    ),
  ];

  static const _artists = [
    ArtistModel(id: 'ar1', name: 'Nova Wave', trackCount: 1),
    ArtistModel(id: 'ar2', name: 'Aria Storm', trackCount: 1),
  ];

  static const _albums = [
    AlbumModel(
      id: 'al1',
      title: 'Neon Horizon',
      artistId: 'ar1',
      artistName: 'Nova Wave',
      songIds: ['s1'],
    ),
  ];

  static const _playlists = [
    PlaylistModel(
      id: 'p1',
      name: 'Focus Flow',
      description: 'Steady beats.',
      songIds: ['s1', 's2'],
      creator: 'spmusic',
    ),
  ];

  int invalidateCacheCalls = 0;

  @override
  Future<List<SongModel>> getSongs() async => _songs;

  @override
  Future<List<ArtistModel>> getArtists() async => _artists;

  @override
  Future<List<AlbumModel>> getAlbums() async => _albums;

  @override
  Future<List<PlaylistModel>> getPlaylists() async => _playlists;

  @override
  void invalidateCache() {
    invalidateCacheCalls++;
  }
}

class _FakeLocalStorageService implements LocalStorageService {
  final Set<String> _favorites = {};
  final List<String> _recentlyPlayed = [];

  @override
  Future<Set<String>> getFavoriteIds() async => Set<String>.of(_favorites);

  @override
  Future<void> setFavoriteIds(Set<String> ids) async {
    _favorites
      ..clear()
      ..addAll(ids);
  }

  @override
  Future<List<String>> getRecentlyPlayedIds() async => _recentlyPlayed;

  @override
  Future<void> recordPlayed(String songId) async {
    _recentlyPlayed
      ..removeWhere((id) => id == songId)
      ..insert(0, songId);
  }
}

void main() {
  late _FakeLocalMusicDataSource dataSource;
  late _FakeLocalStorageService storage;
  late MusicRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeLocalMusicDataSource();
    storage = _FakeLocalStorageService();
    repository = MusicRepositoryImpl(dataSource, storage);
  });

  test('getRecentlyPlayed returns empty when nothing has been played', () async {
    final result = await repository.getRecentlyPlayed();
    expect(result, isEmpty);
  });

  test('recordPlayed then getRecentlyPlayed returns most recent first', () async {
    await repository.recordPlayed('s1');
    await repository.recordPlayed('s2');

    final result = await repository.getRecentlyPlayed();
    expect(result.map((s) => s.id), ['s2', 's1']);
  });

  test('recordPlayed on an already-recorded song moves it to the front', () async {
    await repository.recordPlayed('s1');
    await repository.recordPlayed('s2');
    await repository.recordPlayed('s1');

    final result = await repository.getRecentlyPlayed();
    expect(result.map((s) => s.id), ['s1', 's2']);
  });

  test('searchSongs is case-insensitive and matches partial title', () async {
    final result = await repository.searchSongs('midnight');
    expect(result.length, 1);
    expect(result.first.id, 's1');
  });

  test('searchSongs matches by artist too', () async {
    final result = await repository.searchSongs('aria');
    expect(result.map((s) => s.id), ['s2']);
  });

  test('toggleFavorite then getFavoriteSongs reflects it', () async {
    await repository.toggleFavorite('s1');
    final favorites = await repository.getFavoriteSongs();
    expect(favorites.length, 1);
    expect(favorites.first.id, 's1');
    expect(favorites.first.isFavorite, isTrue);
  });

  test('toggleFavorite twice removes it from favorites', () async {
    await repository.toggleFavorite('s1');
    await repository.toggleFavorite('s1');
    final favorites = await repository.getFavoriteSongs();
    expect(favorites, isEmpty);
  });

  test('getPlaylistById throws for unknown id', () async {
    expect(() => repository.getPlaylistById('unknown'), throwsA(isA<StateError>()));
  });

  test('refresh invalidates the data source cache', () async {
    await repository.refresh();
    expect(dataSource.invalidateCacheCalls, 1);
  });
}
