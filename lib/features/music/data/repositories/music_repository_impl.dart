import '../../domain/entities/album_entity.dart';
import '../../domain/entities/artist_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../../../folders/data/services/folder_filter.dart';
import '../datasources/local_music_data_source.dart';
import '../services/local_storage_service.dart';

class MusicRepositoryImpl implements MusicRepository {
  // Named parameters cannot be private, so this cannot be an initializing formal.
  // ignore: prefer_initializing_formals
  MusicRepositoryImpl(this._dataSource, this._storage, {FolderFilter? folderFilter})
      : _folderFilter = folderFilter;

  final LocalMusicDataSource _dataSource;
  final LocalStorageService _storage;
  final FolderFilter? _folderFilter;

  /// Songs outside excluded folders. Every library query is built on this.
  Future<List<SongEntity>> _librarySongs() async {
    final scanned = await _dataSource.getSongs();
    final filter = _folderFilter;
    if (filter == null) return _applyFavorites(scanned);
    final excluded = filter.excludedAmong({for (final s in scanned) s.folderPath});
    return _applyFavorites([for (final s in scanned) if (!excluded.contains(s.folderPath)) s]);
  }

  /// Same recording copied into several folders is listed once. Favourites,
  /// playlists and recents still resolve through [_librarySongs], so ids of
  /// the hidden copies keep working.
  static List<SongEntity> _withoutContentDuplicates(List<SongEntity> songs) {
    final seen = <String>{};
    return [
      for (final s in songs)
        if (s.fileSize <= 0 || seen.add('${s.title}|${s.artist}|${s.fileSize}|${s.duration.inMilliseconds}')) s,
    ];
  }

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
  Future<List<SongEntity>> getAllSongs() async => _withoutContentDuplicates(await _librarySongs());

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
    final songs = await _librarySongs();
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
    final songs = await _librarySongs();
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
