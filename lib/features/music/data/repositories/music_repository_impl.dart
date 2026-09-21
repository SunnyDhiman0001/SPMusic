import '../../domain/entities/album_entity.dart';
import '../../domain/entities/artist_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/local_music_data_source.dart';
import '../services/local_storage_service.dart';

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl(this._dataSource, this._storage);

  final LocalMusicDataSource _dataSource;
  final LocalStorageService _storage;

  Future<List<SongEntity>> _applyFavorites(List<SongEntity> songs) async {
    final favorites = await _storage.getFavoriteIds();
    return songs.map((s) => s.copyWith(isFavorite: favorites.contains(s.id))).toList();
  }

  @override
  Future<void> refresh() async {
    _dataSource.invalidateCache();
    await getAllSongs();
  }

  @override
  Future<List<SongEntity>> getRecentlyPlayed() async {
    final ids = await _storage.getRecentlyPlayedIds();
    if (ids.isEmpty) return [];
    return getSongsByIds(ids);
  }

  @override
  Future<List<PlaylistEntity>> getMadeForYouPlaylists() async {
    final playlists = await getAllPlaylists();
    return playlists.take(4).toList();
  }

  @override
  Future<List<SongEntity>> getTrendingSongs() async {
    final songs = await getAllSongs();
    if (songs.length <= 10) return songs;
    final shuffled = [...songs]..shuffle();
    return shuffled.take(10).toList();
  }

  @override
  Future<List<ArtistEntity>> getPopularArtists() => getAllArtists();

  @override
  Future<List<SongEntity>> getAllSongs() async {
    final songs = await _dataSource.getSongs();
    return _applyFavorites(songs);
  }

  @override
  Future<List<ArtistEntity>> getAllArtists() async {
    return _dataSource.getArtists();
  }

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    return _dataSource.getAlbums();
  }

  @override
  Future<List<PlaylistEntity>> getAllPlaylists() async {
    return _dataSource.getPlaylists();
  }

  @override
  Future<PlaylistEntity> getPlaylistById(String id) async {
    final playlists = await _dataSource.getPlaylists();
    return playlists.firstWhere(
      (playlist) => playlist.id == id,
      orElse: () => throw StateError('Playlist not found: $id'),
    );
  }

  @override
  Future<List<SongEntity>> getSongsByIds(List<String> ids) async {
    final songs = await getAllSongs();
    final byId = {for (final song in songs) song.id: song};
    return [for (final id in ids) if (byId.containsKey(id)) byId[id]!];
  }

  @override
  Future<List<SongEntity>> searchSongs(String query) async {
    final lowerQuery = query.toLowerCase();
    final songs = await getAllSongs();
    return songs
        .where(
          (song) =>
              song.title.toLowerCase().contains(lowerQuery) ||
              song.artist.toLowerCase().contains(lowerQuery) ||
              song.album.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String query) async {
    final lowerQuery = query.toLowerCase();
    final artists = await getAllArtists();
    return artists.where((artist) => artist.name.toLowerCase().contains(lowerQuery)).toList();
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String query) async {
    final lowerQuery = query.toLowerCase();
    final albums = await getAllAlbums();
    return albums
        .where(
          (album) =>
              album.title.toLowerCase().contains(lowerQuery) ||
              album.artistName.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String query) async {
    final lowerQuery = query.toLowerCase();
    final playlists = await getAllPlaylists();
    return playlists.where((playlist) => playlist.name.toLowerCase().contains(lowerQuery)).toList();
  }

  @override
  Future<List<SongEntity>> getFavoriteSongs() async {
    final songs = await getAllSongs();
    return songs.where((song) => song.isFavorite).toList();
  }

  @override
  Future<void> toggleFavorite(String songId) async {
    final favorites = await _storage.getFavoriteIds();
    if (favorites.contains(songId)) {
      favorites.remove(songId);
    } else {
      favorites.add(songId);
    }
    await _storage.setFavoriteIds(favorites);
  }

  @override
  Future<void> recordPlayed(String songId) => _storage.recordPlayed(songId);
}
