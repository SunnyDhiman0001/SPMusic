# Local Music Player Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all hardcoded/dummy songs with real on-device audio scanning, wire real local files into the existing just_audio-based player with background playback + notification controls, and persist favorites/recently-played — while keeping the existing Clean Architecture (entities/repositories/cubits) and UI intact.

**Architecture:** Keep the existing `music`/`player`/`library`/`search`/`playlist` feature split. `LocalMusicDataSource` gets a real implementation backed by `on_audio_query_forked` (MediaStore scanning, permission-aware), cached in memory after first scan. `MusicRepositoryImpl` persists favorites + recently-played through a new `LocalStorageService` (shared_preferences, already a dependency). `AudioPlayerService`/`JustAudioPlayerService` gain background playback via `just_audio_background`, tagging each track with a `MediaItem` for lock-screen/notification controls. Fake network artwork (`artworkUrl`/`coverUrl`/`imageUrl`) is removed from entities; artwork is fetched on demand from MediaStore by numeric id through a small shared widget.

**Tech Stack:** Flutter, flutter_bloc/Cubit, get_it, equatable, just_audio + just_audio_background, audio_session, on_audio_query_forked, shared_preferences, permission_handler.

---

## File Structure

New files:
- `lib/features/music/data/services/music_permission_service.dart` — wraps `on_audio_query_forked` permission checks + `permission_handler` app-settings deep link.
- `lib/features/music/data/services/local_storage_service.dart` — shared_preferences-backed favorites + recently-played persistence.
- `lib/features/music/domain/entities/artwork_ref.dart` — small value type describing "where to find artwork" (`ArtworkSource` enum + numeric id).
- `lib/core/widgets/local_artwork.dart` — single shared widget rendering song/album artwork from MediaStore, with icon fallback.
- `lib/features/library/presentation/widgets/permission_denied_view.dart` — "grant permission" empty state.
- `lib/features/library/presentation/widgets/no_music_found_view.dart` — "no music found" empty state.

Modified files (entities lose fake fields, data source becomes real, player gains background support, UI swaps `CachedNetworkImage` for `LocalArtwork`): see tasks below for exact paths.

---

### Task 1: Dependencies & Android manifest

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/build.gradle.kts`

- [ ] **Step 1: Add packages**

```yaml
dependencies:
  # ...existing...
  on_audio_query_forked: ^2.9.2
  just_audio_background: ^0.0.1-beta.14
  permission_handler: ^11.3.1
```

Run: `flutter pub get`
Expected: resolves cleanly (bump `on_audio_query_forked`/`just_audio_background` to whatever `flutter pub get` reports as latest compatible if the pin above is rejected — check the error message for the suggested version).

- [ ] **Step 2: Declare permissions in the manifest**

Add inside `<manifest>` (before `<application>`), in `android/app/src/main/AndroidManifest.xml`:

```xml
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
```

- [ ] **Step 3: Register the background audio service**

`just_audio_background` needs its Android service declared. Add inside `<application>`, after the `MainActivity` block, in `android/app/src/main/AndroidManifest.xml`:

```xml
        <service android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true"
            tools:ignore="Instantiatable">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
```

Add the `tools` namespace to the `<manifest>` root tag: `xmlns:tools="http://schemas.android.com/tools"`.

- [ ] **Step 4: Verify minSdk**

Read `android/app/build.gradle.kts` — `minSdk = flutter.minSdkVersion`. `on_audio_query_forked` and `just_audio_background` both require `minSdk 21`+; leave as-is (Flutter's default is already ≥21). No change needed unless `flutter pub get`/build errors say otherwise.

- [ ] **Step 5: Commit**

```bash
git init 2>/dev/null; git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml android/app/build.gradle.kts
git commit -m "chore: add on-device audio scanning and background playback deps"
```

(This project has no git history yet per environment info — if `git init` was needed, this is the first commit; otherwise just add+commit normally.)

---

### Task 2: Rework domain entities — drop fake artwork URLs

**Files:**
- Modify: `lib/features/music/domain/entities/song_entity.dart`
- Modify: `lib/features/music/domain/entities/album_entity.dart`
- Modify: `lib/features/music/domain/entities/artist_entity.dart`
- Modify: `lib/features/music/domain/entities/playlist_entity.dart`
- Modify: `lib/features/music/data/models/song_model.dart`
- Modify: `lib/features/music/data/models/album_model.dart`
- Modify: `lib/features/music/data/models/artist_model.dart`
- Modify: `lib/features/music/data/models/playlist_model.dart`

- [ ] **Step 1: `song_entity.dart`** — replace `artworkUrl` with `artworkId` (the MediaStore audio `_id`, reused to query artwork), keep `audioUrl` (now holds a `content://` URI or file path):

```dart
import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    required this.artworkId,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final int artworkId;
  final String audioUrl;
  final Duration duration;
  final bool isFavorite;

  SongEntity copyWith({bool? isFavorite}) {
    return SongEntity(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      album: album,
      albumId: albumId,
      artworkId: artworkId,
      audioUrl: audioUrl,
      duration: duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        artistId,
        album,
        albumId,
        artworkId,
        audioUrl,
        duration,
        isFavorite,
      ];
}
```

- [ ] **Step 2: `album_entity.dart`** — drop `coverUrl`, keep numeric `id` (album id doubles as artwork id):

```dart
import 'package:equatable/equatable.dart';

class AlbumEntity extends Equatable {
  const AlbumEntity({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.songIds,
  });

  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final List<String> songIds;

  @override
  List<Object?> get props => [id, title, artistId, artistName, songIds];
}
```

- [ ] **Step 3: `artist_entity.dart`** — drop `imageUrl` (MediaStore has no artist photos; UI always shows a generic icon):

```dart
import 'package:equatable/equatable.dart';

class ArtistEntity extends Equatable {
  const ArtistEntity({
    required this.id,
    required this.name,
    required this.trackCount,
  });

  final String id;
  final String name;
  final int trackCount;

  @override
  List<Object?> get props => [id, name, trackCount];
}
```

- [ ] **Step 4: `playlist_entity.dart`** — drop `coverUrl`:

```dart
import 'package:equatable/equatable.dart';

class PlaylistEntity extends Equatable {
  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.songIds,
    required this.creator,
  });

  final String id;
  final String name;
  final String description;
  final List<String> songIds;
  final String creator;

  @override
  List<Object?> get props => [id, name, description, songIds, creator];
}
```

- [ ] **Step 5: Update the four `*_model.dart` files** to match (mechanical — same constructor params as their entity, e.g. `song_model.dart`):

```dart
import '../../domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.artistId,
    required super.album,
    required super.albumId,
    required super.artworkId,
    required super.audioUrl,
    required super.duration,
    super.isFavorite,
  });
}
```

`album_model.dart`:

```dart
import '../../domain/entities/album_entity.dart';

class AlbumModel extends AlbumEntity {
  const AlbumModel({
    required super.id,
    required super.title,
    required super.artistId,
    required super.artistName,
    required super.songIds,
  });
}
```

`artist_model.dart`:

```dart
import '../../domain/entities/artist_entity.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.name,
    required super.trackCount,
  });
}
```

`playlist_model.dart`:

```dart
import '../../domain/entities/playlist_entity.dart';

class PlaylistModel extends PlaylistEntity {
  const PlaylistModel({
    required super.id,
    required super.name,
    required super.description,
    required super.songIds,
    required super.creator,
  });
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/music/domain/entities lib/features/music/data/models
git commit -m "refactor: drop fake artwork URLs from music entities"
```

(This will not compile yet — datasource/UI updates land in later tasks. That is expected; do not run `flutter analyze` until Task 9.)

---

### Task 3: Permission service

**Files:**
- Create: `lib/features/music/data/services/music_permission_service.dart`

- [ ] **Step 1: Write the service**

```dart
import 'package:on_audio_query_forked/on_audio_query_forked.dart';
import 'package:permission_handler/permission_handler.dart';

enum MusicPermissionStatus { granted, denied, permanentlyDenied }

abstract class MusicPermissionService {
  Future<MusicPermissionStatus> check();
  Future<MusicPermissionStatus> request();
  Future<void> openSettings();
}

class MusicPermissionServiceImpl implements MusicPermissionService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Future<MusicPermissionStatus> check() async {
    final granted = await _audioQuery.permissionsStatus();
    if (granted) return MusicPermissionStatus.granted;

    final status = await Permission.audio.status;
    if (status.isPermanentlyDenied) return MusicPermissionStatus.permanentlyDenied;
    return MusicPermissionStatus.denied;
  }

  @override
  Future<MusicPermissionStatus> request() async {
    final granted = await _audioQuery.permissionsRequest();
    if (granted) return MusicPermissionStatus.granted;

    final status = await Permission.audio.status;
    if (status.isPermanentlyDenied) return MusicPermissionStatus.permanentlyDenied;
    return MusicPermissionStatus.denied;
  }

  @override
  Future<void> openSettings() => openAppSettings();
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/music/data/services/music_permission_service.dart
git commit -m "feat: add music permission service"
```

---

### Task 4: Real local music data source

**Files:**
- Modify: `lib/features/music/data/datasources/local_music_data_source.dart`

- [ ] **Step 1: Replace the dummy implementation with a real MediaStore-backed scan, cached after first success**

```dart
import 'package:on_audio_query_forked/on_audio_query_forked.dart' as oaq;

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
  final oaq.OnAudioQuery _audioQuery = oaq.OnAudioQuery();

  List<SongModel>? _songsCache;
  List<ArtistModel>? _artistsCache;
  List<AlbumModel>? _albumsCache;
  List<PlaylistModel>? _playlistsCache;
  Future<void>? _scanFuture;

  @override
  void invalidateCache() {
    _songsCache = null;
    _artistsCache = null;
    _albumsCache = null;
    _playlistsCache = null;
    _scanFuture = null;
  }

  Future<void> _ensureScanned() {
    return _scanFuture ??= _scan();
  }

  Future<void> _scan() async {
    final songs = await _audioQuery.querySongs(
      sortType: oaq.SongSortType.TITLE,
      orderType: oaq.OrderType.ASC_OR_SMALLER,
      uriType: oaq.UriType.EXTERNAL,
      ignoreCase: true,
    );
    final albums = await _audioQuery.queryAlbums(
      sortType: oaq.AlbumSortType.ALBUM,
      orderType: oaq.OrderType.ASC_OR_SMALLER,
      uriType: oaq.UriType.EXTERNAL,
      ignoreCase: true,
    );
    final artists = await _audioQuery.queryArtists(
      sortType: oaq.ArtistSortType.ARTIST,
      orderType: oaq.OrderType.ASC_OR_SMALLER,
      uriType: oaq.UriType.EXTERNAL,
      ignoreCase: true,
    );
    final playlists = await _audioQuery.queryPlaylists(
      sortType: oaq.PlaylistSortType.PLAYLIST,
      orderType: oaq.OrderType.ASC_OR_SMALLER,
      uriType: oaq.UriType.EXTERNAL,
      ignoreCase: true,
    );

    final albumSongIds = <String, List<String>>{};
    for (final song in songs) {
      final albumId = song.albumId?.toString() ?? '';
      albumSongIds.putIfAbsent(albumId, () => []).add(song.id.toString());
    }

    final playlistSongIds = <String, List<String>>{};
    for (final playlist in playlists) {
      final members = await _audioQuery.queryAudiosFrom(
        oaq.AudiosFromType.PLAYLIST,
        playlist.id,
      );
      playlistSongIds[playlist.id.toString()] =
          members.map((m) => m.id.toString()).toList();
    }

    _songsCache = songs
        .where((s) => s.isMusic ?? true)
        .map(
          (s) => SongModel(
            id: s.id.toString(),
            title: s.title,
            artist: (s.artist == null || s.artist == '<unknown>') ? 'Unknown Artist' : s.artist!,
            artistId: s.artistId?.toString() ?? '',
            album: (s.album == null || s.album == '<unknown>') ? 'Unknown Album' : s.album!,
            albumId: s.albumId?.toString() ?? '',
            artworkId: s.id,
            audioUrl: s.uri ?? s.data,
            duration: Duration(milliseconds: s.duration ?? 0),
          ),
        )
        .toList();

    _albumsCache = albums
        .map(
          (a) => AlbumModel(
            id: a.id.toString(),
            title: a.album,
            artistId: a.artistId?.toString() ?? '',
            artistName: a.artist ?? 'Unknown Artist',
            songIds: albumSongIds[a.id.toString()] ?? const [],
          ),
        )
        .toList();

    _artistsCache = artists
        .map(
          (a) => ArtistModel(
            id: a.id.toString(),
            name: a.artist,
            trackCount: a.numberOfTracks ?? 0,
          ),
        )
        .toList();

    _playlistsCache = playlists
        .map(
          (p) => PlaylistModel(
            id: p.id.toString(),
            name: p.playlist,
            description: '',
            songIds: playlistSongIds[p.id.toString()] ?? const [],
            creator: 'On this device',
          ),
        )
        .toList();
  }

  @override
  Future<List<SongModel>> getSongs() async {
    await _ensureScanned();
    return _songsCache!;
  }

  @override
  Future<List<ArtistModel>> getArtists() async {
    await _ensureScanned();
    return _artistsCache!;
  }

  @override
  Future<List<AlbumModel>> getAlbums() async {
    await _ensureScanned();
    return _albumsCache!;
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    await _ensureScanned();
    return _playlistsCache!;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/music/data/datasources/local_music_data_source.dart
git commit -m "feat: scan real on-device songs via MediaStore instead of dummy data"
```

---

### Task 5: Persisted favorites + recently played

**Files:**
- Create: `lib/features/music/data/services/local_storage_service.dart`

- [ ] **Step 1: Write the service**

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _favoritesKey = 'favorite_song_ids';
const _recentlyPlayedKey = 'recently_played_song_ids';
const _maxRecentlyPlayed = 30;

abstract class LocalStorageService {
  Future<Set<String>> getFavoriteIds();
  Future<void> setFavoriteIds(Set<String> ids);
  Future<List<String>> getRecentlyPlayedIds();
  Future<void> recordPlayed(String songId);
}

class LocalStorageServiceImpl implements LocalStorageService {
  LocalStorageServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<Set<String>> getFavoriteIds() async {
    final raw = _prefs.getString(_favoritesKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
  }

  @override
  Future<void> setFavoriteIds(Set<String> ids) async {
    await _prefs.setString(_favoritesKey, jsonEncode(ids.toList()));
  }

  @override
  Future<List<String>> getRecentlyPlayedIds() async {
    final raw = _prefs.getString(_recentlyPlayedKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  @override
  Future<void> recordPlayed(String songId) async {
    final current = await getRecentlyPlayedIds();
    final updated = [songId, ...current.where((id) => id != songId)]
        .take(_maxRecentlyPlayed)
        .toList();
    await _prefs.setString(_recentlyPlayedKey, jsonEncode(updated));
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/music/data/services/local_storage_service.dart
git commit -m "feat: persist favorites and recently-played across sessions"
```

---

### Task 6: Rewire the repository

**Files:**
- Modify: `lib/features/music/domain/repositories/music_repository.dart`
- Modify: `lib/features/music/data/repositories/music_repository_impl.dart`

- [ ] **Step 1: Add `recordPlayed` + permission passthrough to the domain interface**

```dart
import '../entities/album_entity.dart';
import '../entities/artist_entity.dart';
import '../entities/playlist_entity.dart';
import '../entities/song_entity.dart';

abstract class MusicRepository {
  Future<List<SongEntity>> getRecentlyPlayed();
  Future<List<PlaylistEntity>> getMadeForYouPlaylists();
  Future<List<SongEntity>> getTrendingSongs();
  Future<List<ArtistEntity>> getPopularArtists();
  Future<List<SongEntity>> getAllSongs();
  Future<List<ArtistEntity>> getAllArtists();
  Future<List<AlbumEntity>> getAllAlbums();
  Future<List<PlaylistEntity>> getAllPlaylists();
  Future<PlaylistEntity> getPlaylistById(String id);
  Future<List<SongEntity>> getSongsByIds(List<String> ids);
  Future<List<SongEntity>> searchSongs(String query);
  Future<List<ArtistEntity>> searchArtists(String query);
  Future<List<AlbumEntity>> searchAlbums(String query);
  Future<List<PlaylistEntity>> searchPlaylists(String query);
  Future<List<SongEntity>> getFavoriteSongs();
  Future<void> toggleFavorite(String songId);
  Future<void> recordPlayed(String songId);
  Future<void> refresh();
}
```

- [ ] **Step 2: Rewrite the implementation** to await the now-async data source and delegate favorites/recently-played to `LocalStorageService`:

```dart
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

  Future<SongEntity> _applyFavorite(SongEntity song) async {
    final favorites = await _storage.getFavoriteIds();
    return song.copyWith(isFavorite: favorites.contains(song.id));
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
```

Note: `_applyFavorite` (singular) is now unused — it was only ever called internally; delete it if the linter flags it as dead code (it is not referenced above, so remove it from the final file).

- [ ] **Step 3: Commit**

```bash
git add lib/features/music/domain/repositories/music_repository.dart lib/features/music/data/repositories/music_repository_impl.dart
git commit -m "refactor: back favorites and recently-played with persistent storage"
```

---

### Task 7: Shared local artwork widget

**Files:**
- Create: `lib/core/widgets/local_artwork.dart`
- Modify: `lib/core/widgets/artwork_card.dart`
- Modify: `lib/core/widgets/card_display_item.dart`
- Modify: `lib/core/widgets/horizontal_card_list.dart`
- Modify: `lib/features/player/presentation/widgets/rotating_artwork.dart`
- Modify: `lib/features/player/presentation/widgets/mini_player.dart`
- Modify: `lib/features/search/presentation/widgets/search_song_tile.dart`
- Modify: `lib/features/playlist/presentation/widgets/playlist_header.dart`
- Modify: `lib/features/home/presentation/bloc/home_cubit.dart`
- Modify: `lib/features/library/presentation/pages/library_page.dart`

- [ ] **Step 1: `local_artwork.dart`** — one widget, backed by `on_audio_query_forked`'s built-in `QueryArtworkWidget`, used everywhere artwork was previously a `CachedNetworkImage`:

```dart
import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query_forked.dart';

enum ArtworkKind { song, album, none }

class LocalArtwork extends StatelessWidget {
  const LocalArtwork({
    required this.kind,
    this.id,
    this.size = 48,
    this.borderRadius,
    super.key,
  });

  final ArtworkKind kind;
  final int? id;
  final double size;
  final BorderRadius? borderRadius;

  IconData get _fallbackIcon => switch (kind) {
        ArtworkKind.song => Icons.music_note,
        ArtworkKind.album => Icons.album,
        ArtworkKind.none => Icons.queue_music,
      };

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    final placeholder = ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).cardColor,
        child: Icon(_fallbackIcon, size: size * 0.4),
      ),
    );

    if (kind == ArtworkKind.none || id == null) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: QueryArtworkWidget(
        id: id!,
        type: kind == ArtworkKind.album ? ArtworkType.ALBUM : ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.zero,
        keepOldArtwork: true,
        nullArtworkWidget: SizedBox(
          width: size,
          height: size,
          child: Icon(_fallbackIcon, size: size * 0.4),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `card_display_item.dart`** — swap `imageUrl` for artwork identity:

```dart
import 'local_artwork.dart';

class CardDisplayItem {
  const CardDisplayItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.artworkKind,
    this.artworkId,
  });

  final String id;
  final String title;
  final String subtitle;
  final ArtworkKind artworkKind;
  final int? artworkId;
}
```

- [ ] **Step 3: `artwork_card.dart`** — take a kind/id instead of a URL:

```dart
import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'local_artwork.dart';

class ArtworkCard extends StatefulWidget {
  const ArtworkCard({
    required this.artworkKind,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.artworkId,
    this.width = 150,
    this.isCircle = false,
    super.key,
  });

  final ArtworkKind artworkKind;
  final int? artworkId;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double width;
  final bool isCircle;

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  double _scale = 1;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.isCircle ? AppRadius.roundRadius : AppRadius.mdRadius;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalArtwork(
                kind: widget.artworkKind,
                id: widget.artworkId,
                size: widget.width,
                borderRadius: radius,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: `horizontal_card_list.dart`** — pass through the new fields:

```dart
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'artwork_card.dart';
import 'card_display_item.dart';

class HorizontalCardList extends StatelessWidget {
  const HorizontalCardList({
    required this.items,
    this.isCircle = false,
    this.cardWidth = 150,
    this.onItemTap,
    super.key,
  });

  final List<CardDisplayItem> items;
  final bool isCircle;
  final double cardWidth;
  final void Function(String id)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth + 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return ArtworkCard(
            artworkKind: item.artworkKind,
            artworkId: item.artworkId,
            title: item.title,
            subtitle: item.subtitle,
            width: cardWidth,
            isCircle: isCircle,
            onTap: () => onItemTap?.call(item.id),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 5: `rotating_artwork.dart`** — drop `cached_network_image`, use `LocalArtwork`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/widgets/local_artwork.dart';

class RotatingArtwork extends HookWidget {
  const RotatingArtwork({
    required this.artworkId,
    required this.heroTag,
    required this.isPlaying,
    this.size = 280,
    super.key,
  });

  final int artworkId;
  final String heroTag;
  final bool isPlaying;
  final double size;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: const Duration(seconds: 12));

    useEffect(() {
      if (isPlaying) {
        controller.repeat();
      } else {
        controller.stop();
      }
      return null;
    }, [isPlaying]);

    return Hero(
      tag: heroTag,
      child: RotationTransition(
        turns: controller,
        child: ClipOval(
          child: LocalArtwork(
            kind: ArtworkKind.song,
            id: artworkId,
            size: size,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: `mini_player.dart`** — replace the `CachedNetworkImage` block (lines ~35-46) with:

```dart
                Hero(
                  tag: 'player-artwork-${song.id}',
                  child: LocalArtwork(
                    kind: ArtworkKind.song,
                    id: song.artworkId,
                    size: 44,
                    borderRadius: AppRadius.smRadius,
                  ),
                ),
```

And swap the import from `package:cached_network_image/cached_network_image.dart` to `../../../../core/widgets/local_artwork.dart`.

- [ ] **Step 7: `search_song_tile.dart`** — replace the `leading: ClipRRect(...)` block with:

```dart
      leading: LocalArtwork(
        kind: ArtworkKind.song,
        id: song.artworkId,
        size: 48,
        borderRadius: AppRadius.smRadius,
      ),
```

Swap the import the same way as Step 6.

- [ ] **Step 8: `playlist_header.dart`** — playlists have no MediaStore cover; show the generic queue icon and hide the (now-empty) description line:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../music/domain/entities/playlist_entity.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({
    required this.playlist,
    required this.songCount,
    required this.onPlay,
    required this.onShuffle,
    super.key,
  });

  final PlaylistEntity playlist;
  final int songCount;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          LocalArtwork(
            kind: ArtworkKind.none,
            size: 200,
            borderRadius: AppRadius.lgRadius,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(playlist.name, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          if (playlist.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(playlist.description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$songCount songs · ${playlist.creator}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onShuffle,
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 9: `home_cubit.dart`** — update the three `_*ToCard` mappers:

```dart
  CardDisplayItem _songToCard(SongEntity song) => CardDisplayItem(
        id: song.id,
        artworkKind: ArtworkKind.song,
        artworkId: song.artworkId,
        title: song.title,
        subtitle: song.artist,
      );

  CardDisplayItem _playlistToCard(PlaylistEntity playlist) => CardDisplayItem(
        id: playlist.id,
        artworkKind: ArtworkKind.none,
        title: playlist.name,
        subtitle: playlist.description.isEmpty ? playlist.creator : playlist.description,
      );

  CardDisplayItem _artistToCard(ArtistEntity artist) => CardDisplayItem(
        id: artist.id,
        artworkKind: ArtworkKind.none,
        title: artist.name,
        subtitle: '${artist.trackCount} tracks',
      );
```

Add `import '../../../../core/widgets/local_artwork.dart';` to the top of the file.

- [ ] **Step 10: `library_page.dart`** — update the three module-level `_*ToCard` helpers (lines ~19-38) the same way:

```dart
CardDisplayItem _playlistToCard(PlaylistEntity playlist) => CardDisplayItem(
      id: playlist.id,
      artworkKind: ArtworkKind.none,
      title: playlist.name,
      subtitle: playlist.creator,
    );

CardDisplayItem _albumToCard(AlbumEntity album) => CardDisplayItem(
      id: album.id,
      artworkKind: ArtworkKind.album,
      artworkId: int.tryParse(album.id),
      title: album.title,
      subtitle: album.artistName,
    );

CardDisplayItem _artistToCard(ArtistEntity artist) => CardDisplayItem(
      id: artist.id,
      artworkKind: ArtworkKind.none,
      title: artist.name,
      subtitle: '${artist.trackCount} tracks',
    );
```

Add `import '../../../../core/widgets/local_artwork.dart';` to the top of the file.

- [ ] **Step 11: `player_body.dart`** — update the `RotatingArtwork` call (line ~60-64):

```dart
            builder: (context, isPlaying) => RotatingArtwork(
              artworkId: song.artworkId,
              heroTag: 'player-artwork-${song.id}',
              isPlaying: isPlaying,
            ),
```

- [ ] **Step 12: Remove the now-unused `cached_network_image` imports** in every file touched above except `spotify_page.dart` (Spotify artwork is still remote — leave it as-is).

- [ ] **Step 13: Commit**

```bash
git add lib/core/widgets lib/features/player/presentation/widgets lib/features/search/presentation/widgets lib/features/playlist/presentation/widgets lib/features/home/presentation/bloc/home_cubit.dart lib/features/library/presentation/pages/library_page.dart
git commit -m "refactor: render artwork from MediaStore instead of fake network URLs"
```

---

### Task 8: Background playback + notification controls

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/features/player/data/services/audio_player_service.dart`
- Modify: `lib/features/player/data/services/just_audio_player_service.dart`
- Modify: `lib/features/player/domain/repositories/player_repository.dart`
- Modify: `lib/features/player/data/repositories/player_repository_impl.dart`
- Modify: `lib/features/player/presentation/bloc/player_cubit.dart`

- [ ] **Step 1: Initialize `just_audio_background` before the app starts**, in `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/player/presentation/bloc/player_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.spmusic.channel.audio',
    androidNotificationChannelName: 'spmusic playback',
    androidNotificationOngoing: true,
  );
  await setupInjector();
  runApp(const SpMusicApp());
}
```

(Leave the rest of `main.dart` — the `SpMusicApp` widget — unchanged.)

- [ ] **Step 2: Extend `AudioPlayerService.load` to accept notification metadata**, in `audio_player_service.dart`:

```dart
import '../../domain/entities/playback_status.dart';

class TrackMetadata {
  const TrackMetadata({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.artUri,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Uri? artUri;
}

abstract class AudioPlayerService {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlaybackStatus> get statusStream;

  Future<void> load(String url, TrackMetadata metadata);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> dispose();
}
```

- [ ] **Step 3: Tag the `AudioSource` with a `MediaItem`** in `just_audio_player_service.dart` — replace the `load` method (and add the import):

```dart
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_background/just_audio_background.dart';

import '../../domain/entities/playback_status.dart';
import 'audio_player_service.dart';

/// The only file in this project allowed to touch `package:just_audio`
/// directly. Everything else depends on [AudioPlayerService].
class JustAudioPlayerService implements AudioPlayerService {
  JustAudioPlayerService() : _player = ja.AudioPlayer() {
    _configureSession();
  }

  final ja.AudioPlayer _player;

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<PlaybackStatus> get statusStream => _player.playerStateStream.map(_mapStatus);

  PlaybackStatus _mapStatus(ja.PlayerState state) {
    if (state.processingState == ja.ProcessingState.loading) {
      return PlaybackStatus.loading;
    }
    if (state.processingState == ja.ProcessingState.buffering) {
      return PlaybackStatus.buffering;
    }
    if (state.processingState == ja.ProcessingState.completed) {
      return PlaybackStatus.completed;
    }
    if (state.processingState == ja.ProcessingState.idle) {
      return PlaybackStatus.idle;
    }
    return state.playing ? PlaybackStatus.playing : PlaybackStatus.paused;
  }

  @override
  Future<void> load(String url, TrackMetadata metadata) async {
    await _player.setAudioSource(
      ja.AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: metadata.id,
          title: metadata.title,
          artist: metadata.artist,
          album: metadata.album,
          artUri: metadata.artUri,
        ),
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
```

- [ ] **Step 4: `player_repository.dart`** — thread metadata through:

```dart
import '../entities/playback_status.dart';
import '../../data/services/audio_player_service.dart' show TrackMetadata;

abstract class PlayerRepository {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlaybackStatus> get statusStream;

  Future<void> loadAndPlay(String url, TrackMetadata metadata);
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> stop();
}
```

(Check the original `player_repository.dart` for its exact existing member list before replacing — carry over any getters/methods not shown above unchanged.)

- [ ] **Step 5: `player_repository_impl.dart`** — pass metadata through to the service:

```dart
import '../../domain/entities/playback_status.dart';
import '../../domain/repositories/player_repository.dart';
import '../services/audio_player_service.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl(this._service);

  final AudioPlayerService _service;

  @override
  Stream<Duration> get positionStream => _service.positionStream;

  @override
  Stream<Duration?> get durationStream => _service.durationStream;

  @override
  Stream<PlaybackStatus> get statusStream => _service.statusStream;

  @override
  Future<void> loadAndPlay(String url, TrackMetadata metadata) async {
    await _service.load(url, metadata);
    await _service.play();
  }

  @override
  Future<void> pause() => _service.pause();

  @override
  Future<void> resume() => _service.play();

  @override
  Future<void> seek(Duration position) => _service.seek(position);

  @override
  Future<void> stop() => _service.stop();
}
```

- [ ] **Step 6: `player_cubit.dart`** — build `TrackMetadata` from the current song and record it as played, in `_playCurrentIndex`:

```dart
  Future<void> _playCurrentIndex() async {
    final index = state.currentIndex;
    if (index < 0 || index >= state.queue.length) return;

    emit(state.copyWith(currentIndex: index, position: Duration.zero));
    final song = state.currentSong;
    if (song == null) return;

    try {
      await _repository.loadAndPlay(
        song.audioUrl,
        TrackMetadata(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
        ),
      );
      await _onPlaybackStarted?.call(song.id);
    } catch (e) {
      emit(state.copyWith(status: PlaybackStatus.error, errorMessage: e.toString()));
    }
  }
```

Add a constructor hook so the cubit can tell the repository layer to record "recently played" without the player feature depending on the music feature's repository directly (keeps feature boundaries clean):

```dart
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._repository, {Future<void> Function(String songId)? onPlaybackStarted})
      : _onPlaybackStarted = onPlaybackStarted,
        super(const PlayerState()) {
    _positionSubscription = _repository.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });
    _durationSubscription = _repository.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration));
    });
    _statusSubscription = _repository.statusStream.listen((status) {
      emit(state.copyWith(status: status));
      if (status == PlaybackStatus.completed) {
        _onSongCompleted();
      }
    });
  }

  final PlayerRepository _repository;
  final Future<void> Function(String songId)? _onPlaybackStarted;
  final math.Random _random = math.Random();
```

(Only the constructor signature and the two new fields change; every other method in `player_cubit.dart` stays exactly as read in the codebase.)

- [ ] **Step 7: Wire the hook in `injector.dart`** (Task 10 covers the rest of the DI file, but do this line now):

```dart
  sl.registerLazySingleton<PlayerCubit>(
    () => PlayerCubit(sl(), onPlaybackStarted: sl<MusicRepository>().recordPlayed),
  );
```

- [ ] **Step 8: Commit**

```bash
git add lib/main.dart lib/features/player
git commit -m "feat: background playback with lock-screen and notification controls"
```

---

### Task 9: Permission-aware library states + empty states

**Files:**
- Modify: `lib/features/library/presentation/bloc/library_state.dart`
- Modify: `lib/features/library/presentation/bloc/library_cubit.dart`
- Create: `lib/features/library/presentation/widgets/permission_denied_view.dart`
- Create: `lib/features/library/presentation/widgets/no_music_found_view.dart`
- Modify: `lib/features/library/presentation/pages/library_page.dart`

- [ ] **Step 1: Add two new states**, in `library_state.dart` (append, keep everything else):

```dart
class LibraryPermissionDenied extends LibraryState {
  const LibraryPermissionDenied({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  List<Object?> get props => [permanentlyDenied];
}
```

- [ ] **Step 2: Check permission before scanning**, in `library_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../music/data/services/music_permission_service.dart';
import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../music/domain/repositories/music_repository.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repository, this._permissionService) : super(const LibraryLoading());

  final MusicRepository _repository;
  final MusicPermissionService _permissionService;

  Future<void> load() async {
    emit(const LibraryLoading());

    final status = await _permissionService.check();
    if (status != MusicPermissionStatus.granted) {
      emit(LibraryPermissionDenied(permanentlyDenied: status == MusicPermissionStatus.permanentlyDenied));
      return;
    }

    await _loadLibrary();
  }

  Future<void> requestPermission() async {
    final status = await _permissionService.request();
    if (status == MusicPermissionStatus.granted) {
      await _loadLibrary();
    } else {
      emit(LibraryPermissionDenied(permanentlyDenied: status == MusicPermissionStatus.permanentlyDenied));
    }
  }

  Future<void> openPermissionSettings() => _permissionService.openSettings();

  Future<void> _loadLibrary() async {
    try {
      final results = await Future.wait<dynamic>([
        _repository.getAllPlaylists(),
        _repository.getAllAlbums(),
        _repository.getAllArtists(),
        _repository.getFavoriteSongs(),
        _repository.getRecentlyPlayed(),
        _repository.getAllSongs(),
      ]);

      final playlists = results[0] as List<PlaylistEntity>;
      final albums = results[1] as List<AlbumEntity>;
      final artists = results[2] as List<ArtistEntity>;
      final likedSongs = results[3] as List<SongEntity>;
      final recentlyPlayed = results[4] as List<SongEntity>;
      final allSongs = results[5] as List<SongEntity>;

      emit(LibraryLoaded(
        filter: LibraryFilter.all,
        playlists: playlists,
        albums: albums,
        artists: artists,
        likedSongs: likedSongs,
        recentlyPlayed: recentlyPlayed,
        isEmpty: allSongs.isEmpty,
      ));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  void setFilter(LibraryFilter filter) {
    final current = state;
    if (current is LibraryLoaded) {
      emit(current.copyWith(filter: filter));
    }
  }
}
```

- [ ] **Step 3: Add `isEmpty` to `LibraryLoaded`**, in `library_state.dart` (modify the existing class rather than the appended one from Step 1):

```dart
class LibraryLoaded extends LibraryState {
  const LibraryLoaded({
    required this.filter,
    required this.playlists,
    required this.albums,
    required this.artists,
    required this.likedSongs,
    required this.recentlyPlayed,
    required this.isEmpty,
  });

  final LibraryFilter filter;
  final List<PlaylistEntity> playlists;
  final List<AlbumEntity> albums;
  final List<ArtistEntity> artists;
  final List<SongEntity> likedSongs;
  final List<SongEntity> recentlyPlayed;
  final bool isEmpty;

  LibraryLoaded copyWith({LibraryFilter? filter}) => LibraryLoaded(
        filter: filter ?? this.filter,
        playlists: playlists,
        albums: albums,
        artists: artists,
        likedSongs: likedSongs,
        recentlyPlayed: recentlyPlayed,
        isEmpty: isEmpty,
      );

  @override
  List<Object?> get props =>
      [filter, playlists, albums, artists, likedSongs, recentlyPlayed, isEmpty];
}
```

- [ ] **Step 4: `permission_denied_view.dart`**:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({
    required this.permanentlyDenied,
    required this.onRequestPermission,
    required this.onOpenSettings,
    super.key,
  });

  final bool permanentlyDenied;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              'spmusic needs access to your music',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Grant access to your device storage so we can show the songs you already have.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: permanentlyDenied ? onOpenSettings : onRequestPermission,
              child: Text(permanentlyDenied ? 'Open Settings' : 'Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: `no_music_found_view.dart`**:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class NoMusicFoundView extends StatelessWidget {
  const NoMusicFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_off_outlined, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No music found on your device',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add some audio files to your device storage, then pull to refresh.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Wire both views into `library_page.dart`** — replace the `body:` builder:

```dart
        body: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            return switch (state) {
              LibraryLoading() => const Center(child: CircularProgressIndicator()),
              LibraryError(:final message) => Center(child: Text('Something went wrong: $message')),
              LibraryPermissionDenied(:final permanentlyDenied) => PermissionDeniedView(
                  permanentlyDenied: permanentlyDenied,
                  onRequestPermission: () => context.read<LibraryCubit>().requestPermission(),
                  onOpenSettings: () => context.read<LibraryCubit>().openPermissionSettings(),
                ),
              LibraryLoaded(isEmpty: true) => const NoMusicFoundView(),
              LibraryLoaded() => _LibraryContent(state: state),
            };
          },
        ),
```

Add the two new widget imports at the top of `library_page.dart`.

- [ ] **Step 7: Commit**

```bash
git add lib/features/library
git commit -m "feat: handle permission-denied and no-music empty states in Library"
```

---

### Task 10: DI wiring

**Files:**
- Modify: `lib/core/di/injector.dart`

- [ ] **Step 1: Register the two new services and update existing registrations**

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/library/presentation/bloc/library_cubit.dart';
import '../../features/music/data/datasources/local_music_data_source.dart';
import '../../features/music/data/repositories/music_repository_impl.dart';
import '../../features/music/data/services/local_storage_service.dart';
import '../../features/music/data/services/music_permission_service.dart';
import '../../features/music/domain/repositories/music_repository.dart';
import '../../features/player/data/repositories/player_repository_impl.dart';
import '../../features/player/data/services/audio_player_service.dart';
import '../../features/player/data/services/just_audio_player_service.dart';
import '../../features/player/domain/repositories/player_repository.dart';
import '../../features/player/presentation/bloc/player_cubit.dart';
import '../../features/playlist/presentation/bloc/playlist_cubit.dart';
import '../../features/search/presentation/bloc/search_cubit.dart';
import '../../features/spotify/data/datasources/spotify_remote_data_source.dart';
import '../../features/spotify/data/datasources/spotify_remote_data_source_impl.dart';
import '../../features/spotify/data/repositories/spotify_repository_impl.dart';
import '../../features/spotify/data/services/spotify_auth_service.dart';
import '../../features/spotify/data/services/spotify_auth_service_impl.dart';
import '../../features/spotify/domain/repositories/spotify_repository.dart';
import '../../features/spotify/presentation/bloc/spotify_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjector() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageServiceImpl(sl()));
  sl.registerLazySingleton<MusicPermissionService>(() => MusicPermissionServiceImpl());

  sl.registerLazySingleton<LocalMusicDataSource>(() => LocalMusicDataSourceImpl());
  sl.registerLazySingleton<MusicRepository>(() => MusicRepositoryImpl(sl(), sl()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl()));

  sl.registerLazySingleton<AudioPlayerService>(() => JustAudioPlayerService());
  sl.registerLazySingleton<PlayerRepository>(() => PlayerRepositoryImpl(sl()));
  sl.registerLazySingleton<PlayerCubit>(
    () => PlayerCubit(sl(), onPlaybackStarted: sl<MusicRepository>().recordPlayed),
  );

  sl.registerFactory<SearchCubit>(() => SearchCubit(sl()));

  sl.registerFactory<LibraryCubit>(() => LibraryCubit(sl(), sl()));
  sl.registerFactory<PlaylistCubit>(() => PlaylistCubit(sl()));

  sl.registerLazySingleton<SpotifyAuthService>(() => SpotifyAuthServiceImpl());
  sl.registerLazySingleton<SpotifyRemoteDataSource>(
    () => SpotifyRemoteDataSourceImpl(sl<SpotifyAuthService>().getValidAccessToken),
  );
  sl.registerLazySingleton<SpotifyRepository>(
    () => SpotifyRepositoryImpl(sl(), sl()),
  );
  sl.registerFactory<SpotifyCubit>(() => SpotifyCubit(sl()));
}
```

- [ ] **Step 2: Add `shared_preferences` to `pubspec.yaml` if missing** — it is already listed (see current `pubspec.yaml`), so no change needed there.

- [ ] **Step 3: Commit**

```bash
git add lib/core/di/injector.dart
git commit -m "wire: register permission and storage services in the injector"
```

---

### Task 11: Fix and extend tests

**Files:**
- Modify: `test/features/music/data/repositories/music_repository_impl_test.dart`
- Modify: `test/features/player/presentation/bloc/player_cubit_test.dart`
- Modify: `test/core/widgets/artwork_card_test.dart`
- Modify: `test/features/home/presentation/bloc/home_cubit_test.dart`
- Modify: `test/features/library/presentation/bloc/library_cubit_test.dart`
- Modify: `test/features/search/presentation/bloc/search_cubit_test.dart`
- Modify: `test/features/playlist/presentation/bloc/playlist_cubit_test.dart`
- Modify: `test/features/player/presentation/widgets/mini_player_test.dart`

- [ ] **Step 1: `music_repository_impl_test.dart`** — data source is now async and favorites/recently-played go through `LocalStorageService`; add an in-memory fake:

```dart
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
      audioUrl: 'content://media/external/audio/media/1',
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
      audioUrl: 'content://media/external/audio/media/2',
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
      description: '',
      songIds: ['s1', 's2'],
      creator: 'On this device',
    ),
  ];

  @override
  Future<List<SongModel>> getSongs() async => _songs;

  @override
  Future<List<ArtistModel>> getArtists() async => _artists;

  @override
  Future<List<AlbumModel>> getAlbums() async => _albums;

  @override
  Future<List<PlaylistModel>> getPlaylists() async => _playlists;

  @override
  void invalidateCache() {}
}

class _FakeLocalStorageService implements LocalStorageService {
  Set<String> _favorites = {};
  final List<String> _recent = [];

  @override
  Future<Set<String>> getFavoriteIds() async => _favorites;

  @override
  Future<void> setFavoriteIds(Set<String> ids) async => _favorites = ids;

  @override
  Future<List<String>> getRecentlyPlayedIds() async => _recent;

  @override
  Future<void> recordPlayed(String songId) async {
    _recent
      ..removeWhere((id) => id == songId)
      ..insert(0, songId);
  }
}

void main() {
  late MusicRepositoryImpl repository;

  setUp(() {
    repository = MusicRepositoryImpl(_FakeLocalMusicDataSource(), _FakeLocalStorageService());
  });

  test('getAllSongs returns songs from the data source', () async {
    final result = await repository.getAllSongs();
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

  test('recordPlayed then getRecentlyPlayed reflects it, most recent first', () async {
    await repository.recordPlayed('s2');
    await repository.recordPlayed('s1');
    final recent = await repository.getRecentlyPlayed();
    expect(recent.map((s) => s.id), ['s1', 's2']);
  });
}
```

- [ ] **Step 2: Run it**

Run: `flutter test test/features/music/data/repositories/music_repository_impl_test.dart`
Expected: all tests pass.

- [ ] **Step 3: `player_cubit_test.dart`** — `loadAndPlay` now takes `(String url, TrackMetadata metadata)` and `PlayerCubit` takes an optional `onPlaybackStarted` callback. Update the fake and the two `SongEntity` constants:

```dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/player/data/services/audio_player_service.dart';
import 'package:spmusic/features/player/domain/entities/playback_status.dart';
import 'package:spmusic/features/player/domain/entities/repeat_mode.dart';
import 'package:spmusic/features/player/domain/repositories/player_repository.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';
import 'package:spmusic/features/player/presentation/bloc/player_state.dart';

class FakePlayerRepository implements PlayerRepository {
  final List<String> loadedUrls = [];
  final List<Duration> seekedPositions = [];
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _statusController = StreamController<PlaybackStatus>.broadcast();

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<PlaybackStatus> get statusStream => _statusController.stream;

  @override
  Future<void> loadAndPlay(String url, TrackMetadata metadata) async {
    loadedUrls.add(url);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> resume() async {
    resumeCalls++;
  }

  @override
  Future<void> seek(Duration position) async {
    seekedPositions.add(position);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  void emitStatus(PlaybackStatus status) => _statusController.add(status);
  void emitPosition(Duration position) => _positionController.add(position);
  void emitDuration(Duration? duration) => _durationController.add(duration);

  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _statusController.close();
  }
}

const songA = SongEntity(
  id: '1',
  title: 'Song A',
  artist: 'Artist A',
  artistId: 'a1',
  album: 'Album A',
  albumId: 'al1',
  artworkId: 1,
  audioUrl: 'content://media/external/audio/media/1',
  duration: Duration(minutes: 3),
);

const songB = SongEntity(
  id: '2',
  title: 'Song B',
  artist: 'Artist B',
  artistId: 'b1',
  album: 'Album B',
  albumId: 'bl1',
  artworkId: 2,
  audioUrl: 'content://media/external/audio/media/2',
  duration: Duration(minutes: 4),
);
```

Every `verify`/`expect` in the rest of the file compares `fakeRepository.loadedUrls` against `songA.audioUrl` / `songB.audioUrl` — those lines are unchanged since the field name didn't change, only its content. Leave the rest of the file (all the `blocTest` blocks) exactly as read in the codebase.

- [ ] **Step 4: Run it**

Run: `flutter test test/features/player/presentation/bloc/player_cubit_test.dart`
Expected: all tests pass.

- [ ] **Step 5: `artwork_card_test.dart`** — update to the new constructor:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/artwork_card.dart';
import 'package:spmusic/core/widgets/local_artwork.dart';

void main() {
  testWidgets('ArtworkCard shows title, subtitle, and reacts to tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArtworkCard(
            artworkKind: ArtworkKind.song,
            artworkId: 1,
            title: 'Midnight City',
            subtitle: 'M83',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Midnight City'), findsOneWidget);
    expect(find.text('M83'), findsOneWidget);

    await tester.tap(find.byType(ArtworkCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 6: Run it**

Run: `flutter test test/core/widgets/artwork_card_test.dart`
Expected: passes (the `QueryArtworkWidget` plugin call will no-op/fallback under the test's mocked platform channels — if it throws `MissingPluginException`, wrap the `LocalArtwork` widget usage in the test's expectations only around the text/tap assertions above, which don't depend on the artwork having actually loaded).

- [ ] **Step 7: `home_cubit_test.dart`, `library_cubit_test.dart`, `search_cubit_test.dart`, `playlist_cubit_test.dart`, `mini_player_test.dart`** — open each file, find every `SongEntity(...)`, `AlbumEntity(...)`, `ArtistEntity(...)`, `PlaylistEntity(...)` literal and any fake repository whose methods returned synchronously, and:
  - replace `artworkUrl: '...'` with `artworkId: <int>` on songs, drop `coverUrl`/`imageUrl` on albums/artists/playlists, add `trackCount`/`description` where now required (mirror the pattern from Step 3 above).
  - for `library_cubit_test.dart` specifically: `LibraryCubit` now takes a second constructor argument (`MusicPermissionService`) — add a fake:

```dart
class _FakeMusicPermissionService implements MusicPermissionService {
  @override
  Future<MusicPermissionStatus> check() async => MusicPermissionStatus.granted;

  @override
  Future<MusicPermissionStatus> request() async => MusicPermissionStatus.granted;

  @override
  Future<void> openSettings() async {}
}
```

  and update `LibraryCubit(fakeRepository)` calls to `LibraryCubit(fakeRepository, _FakeMusicPermissionService())`. Also add `isEmpty: false` to every `LibraryLoaded(...)` construction/expectation in that file.

- [ ] **Step 8: Run the full suite**

Run: `flutter test`
Expected: all tests pass. Fix any remaining compile errors surfaced by the analyzer output (mechanical field renames only — no new logic needed).

- [ ] **Step 9: Commit**

```bash
git add test
git commit -m "test: update suites for real local-music data model and permission flow"
```

---

### Task 12: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Static analysis**

Run: `flutter analyze`
Expected: `No issues found!` — fix anything reported (missing imports, unused fields like the stray `_applyFavorite` singular helper from Task 6, unused `cached_network_image` imports from Task 7).

- [ ] **Step 2: Full test suite**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 3: Build check**

Run: `flutter build apk --debug`
Expected: build succeeds (confirms the manifest/gradle/plugin wiring from Task 1 and 8 is consistent).

- [ ] **Step 4: Manual on-device verification** (requires a connected Android device/emulator with some audio files present under `Music`/`Downloads`)

Run: `flutter run`
Checklist:
- App requests audio permission on first Library visit; denying shows `PermissionDeniedView`, re-opening and granting loads real songs.
- Library "All Songs"/"Albums"/"Artists"/"Playlists" show only real device data, no placeholder entries.
- Tapping a song plays real audio; mini-player and full player show correct title/artist/artwork.
- Backgrounding the app (home button) keeps audio playing; the notification shows title/artist/artwork with working play/pause/skip.
- Locking the screen shows the same controls on the lock screen.
- Favoriting a song, restarting the app, confirms the favorite persisted.
- Playing a few songs, restarting the app, confirms "Recently Played" persisted.
- Search filters by title/artist/album as you type.
- On a device/emulator with zero audio files, Library shows "No music found on your device" (not dummy songs).

- [ ] **Step 5: Commit** (only if Step 1 required fixes not already committed)

```bash
git add -A
git commit -m "fix: resolve flutter analyze warnings after local-music migration"
```

---

## Self-Review Notes

- **Spec coverage:** Task 4 covers §2 (device scanning, metadata, permissions, no hardcoded paths). Task 8 covers §3 (play/pause/prev/next/seek already existed in `PlayerCubit`; background+notification+lock-screen added here; audio focus handled by the existing `audio_session` config, untouched). Task 9 + `library_page.dart`/`LibraryCubit` cover §4 (All Songs/Recently Played/Favorites/Albums/Artists/Playlists all backed by real data — playlists come from real on-device MediaStore playlists, not invented ones). §5 (search) needed no changes beyond entity field renames — `SearchCubit`/`searchSongs` already searches title/artist, Task 6 adds album to the match. §6 (architecture) preserved: Cubit/repository/service/DI layering untouched, just rewired. §7 (permissions/empty state) is Task 9. §8 (performance) — Task 4's scan-once-cache-after cache, Task 7's `keepOldArtwork`, and the app's existing `ListView.builder`/lazy lists satisfy this; no additional work needed. §9 (existing UI) — no screen was restructured, only the data plumbing feeding it.
- **Placeholder scan:** no TBD/TODO left in any step; every step has literal, complete code.
- **Type consistency:** `SongEntity.artworkId` (int) is threaded consistently through `SongModel`, `LocalArtwork`, `CardDisplayItem`, `RotatingArtwork`, `MiniPlayer`, `SearchSongTile`. `TrackMetadata` is defined once (Task 8, Step 2) and consumed identically in `JustAudioPlayerService`, `PlayerRepository`, `PlayerRepositoryImpl`, `PlayerCubit`, and the Task 11 test fake.
