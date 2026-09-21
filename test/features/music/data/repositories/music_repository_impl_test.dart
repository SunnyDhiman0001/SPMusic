import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/music/data/datasources/local_music_data_source.dart';
import 'package:spmusic/features/music/data/models/album_model.dart';
import 'package:spmusic/features/music/data/models/artist_model.dart';
import 'package:spmusic/features/music/data/models/playlist_model.dart';
import 'package:spmusic/features/music/data/models/song_model.dart';
import 'package:spmusic/features/music/data/repositories/music_repository_impl.dart';

class _FakeLocalMusicDataSource implements LocalMusicDataSource {
  static const _songs = [
    SongModel(
      id: 's1',
      title: 'Midnight Drive',
      artist: 'Nova Wave',
      artistId: 'ar1',
      album: 'Neon Horizon',
      albumId: 'al1',
      artworkUrl: 'https://picsum.photos/seed/album1/400',
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
      artworkUrl: 'https://picsum.photos/seed/album2/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      duration: Duration(minutes: 3, seconds: 12),
    ),
  ];

  static const _artists = [
    ArtistModel(id: 'ar1', name: 'Nova Wave', imageUrl: 'https://picsum.photos/seed/artist1/400'),
    ArtistModel(id: 'ar2', name: 'Aria Storm', imageUrl: 'https://picsum.photos/seed/artist2/400'),
  ];

  static const _albums = [
    AlbumModel(
      id: 'al1',
      title: 'Neon Horizon',
      artistId: 'ar1',
      artistName: 'Nova Wave',
      coverUrl: 'https://picsum.photos/seed/album1/400',
      songIds: ['s1'],
    ),
  ];

  static const _playlists = [
    PlaylistModel(
      id: 'p1',
      name: 'Focus Flow',
      description: 'Steady beats.',
      coverUrl: 'https://picsum.photos/seed/playlist1/400',
      songIds: ['s1', 's2'],
      creator: 'spmusic',
    ),
  ];

  @override
  List<SongModel> getSongs() => _songs;

  @override
  List<ArtistModel> getArtists() => _artists;

  @override
  List<AlbumModel> getAlbums() => _albums;

  @override
  List<PlaylistModel> getPlaylists() => _playlists;
}

void main() {
  late MusicRepositoryImpl repository;

  setUp(() {
    repository = MusicRepositoryImpl(_FakeLocalMusicDataSource());
  });

  test('getRecentlyPlayed returns the expected slice', () async {
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
}
