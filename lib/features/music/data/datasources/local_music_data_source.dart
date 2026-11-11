import 'package:on_audio_query_forked/on_audio_query.dart' as oaq;

import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

abstract class LocalMusicDataSource {
  Future<List<SongModel>> getSongs();
  Future<List<ArtistModel>> getArtists();
  Future<List<AlbumModel>> getAlbums();
  Future<List<PlaylistModel>> getPlaylists();

  /// Forces the next call to each getter above to re-scan the device
  /// instead of returning the cached scan.
  void invalidateCache();
}

class LocalMusicDataSourceImpl implements LocalMusicDataSource {
  LocalMusicDataSourceImpl({oaq.OnAudioQuery? audioQuery})
      : _audioQuery = audioQuery ?? oaq.OnAudioQuery();

  final oaq.OnAudioQuery _audioQuery;

  Future<void>? _scanFuture;

  List<SongModel> _songs = const [];
  List<ArtistModel> _artists = const [];
  List<AlbumModel> _albums = const [];
  List<PlaylistModel> _playlists = const [];

  Future<void> _ensureScanned() {
    return _scanFuture ??= _scan();
  }

  Future<void> _scan() async {
    // Some on_audio_query_forked native queries (observed on
    // on_audio_query_android_v1_8) throw/double-reply when called before the
    // audio permission is granted. Never touch the device query without it.
    final hasPermission = await _audioQuery.permissionsStatus();
    if (!hasPermission) {
      _songs = const [];
      _albums = const [];
      _artists = const [];
      _playlists = const [];
      return;
    }

    final rawSongs = await _audioQuery.querySongs();

    final songs = <SongModel>[];
    final songIdsByAlbumId = <String, List<String>>{};

    final seenPaths = <String>{};
    for (final rawSong in rawSongs) {
      // Trust MediaStore's own classification: ringtones, alarms and
      // notification sounds are not music even if they are audio files.
      if (rawSong.isMusic == false ||
          rawSong.isRingtone == true ||
          rawSong.isAlarm == true ||
          rawSong.isNotification == true) {
        continue;
      }
      // MediaStore can list one physical file more than once.
      if (!seenPaths.add(rawSong.data)) continue;

      final id = rawSong.id.toString();
      final albumId = rawSong.albumId?.toString() ?? '';
      final artistId = rawSong.artistId?.toString() ?? '';

      final artist = rawSong.artist;
      final album = rawSong.album;

      final song = SongModel(
        id: id,
        title: rawSong.title,
        artist: (artist == null || artist == '<unknown>')
            ? 'Unknown Artist'
            : artist,
        artistId: artistId,
        album: (album == null || album == '<unknown>')
            ? 'Unknown Album'
            : album,
        albumId: albumId,
        artworkId: rawSong.id,
        audioUrl: rawSong.uri ?? rawSong.data,
        duration: Duration(milliseconds: rawSong.duration ?? 0),
        folderPath: _parentDirectory(rawSong.data),
        fileSize: rawSong.size,
      );

      songs.add(song);

      if (albumId.isNotEmpty) {
        songIdsByAlbumId.putIfAbsent(albumId, () => []).add(id);
      }
    }

    final rawAlbums = await _audioQuery.queryAlbums();
    final albums = rawAlbums.map((rawAlbum) {
      final albumId = rawAlbum.id.toString();
      return AlbumModel(
        id: albumId,
        title: rawAlbum.album,
        artistId: rawAlbum.artistId?.toString() ?? '',
        artistName: rawAlbum.artist ?? 'Unknown Artist',
        songIds: songIdsByAlbumId[albumId] ?? const [],
      );
    }).toList();

    final rawArtists = await _audioQuery.queryArtists();
    final artists = rawArtists.map((rawArtist) {
      return ArtistModel(
        id: rawArtist.id.toString(),
        name: rawArtist.artist,
        trackCount: rawArtist.numberOfTracks ?? 0,
      );
    }).toList();

    final rawPlaylists = await _audioQuery.queryPlaylists();
    final playlists = <PlaylistModel>[];
    for (final rawPlaylist in rawPlaylists) {
      final rawPlaylistSongs = await _audioQuery.queryAudiosFrom(
        oaq.AudiosFromType.PLAYLIST,
        rawPlaylist.id,
      );

      playlists.add(
        PlaylistModel(
          id: rawPlaylist.id.toString(),
          name: rawPlaylist.playlist,
          description: '',
          songIds: rawPlaylistSongs.map((s) => s.id.toString()).toList(),
          creator: 'On this device',
        ),
      );
    }

    _songs = songs;
    _albums = albums;
    _artists = artists;
    _playlists = playlists;
  }

  static String _parentDirectory(String filePath) {
    final index = filePath.lastIndexOf('/');
    return index <= 0 ? '' : filePath.substring(0, index);
  }

  @override
  Future<List<SongModel>> getSongs() async {
    await _ensureScanned();
    return _songs;
  }

  @override
  Future<List<ArtistModel>> getArtists() async {
    await _ensureScanned();
    return _artists;
  }

  @override
  Future<List<AlbumModel>> getAlbums() async {
    await _ensureScanned();
    return _albums;
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    await _ensureScanned();
    return _playlists;
  }

  @override
  void invalidateCache() {
    _scanFuture = null;
    _songs = const [];
    _artists = const [];
    _albums = const [];
    _playlists = const [];
  }
}
