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
      await _repository.refresh();
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
