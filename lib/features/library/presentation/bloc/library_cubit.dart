import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../music/domain/repositories/music_repository.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repository) : super(const LibraryLoading());

  final MusicRepository _repository;

  Future<void> load() async {
    emit(const LibraryLoading());
    try {
      final results = await Future.wait<dynamic>([
        _repository.getAllPlaylists(),
        _repository.getAllAlbums(),
        _repository.getAllArtists(),
        _repository.getFavoriteSongs(),
        _repository.getAllSongs(),
      ]);

      final playlists = results[0] as List<PlaylistEntity>;
      final albums = results[1] as List<AlbumEntity>;
      final artists = results[2] as List<ArtistEntity>;
      final likedSongs = results[3] as List<SongEntity>;
      final allSongs = results[4] as List<SongEntity>;

      emit(LibraryLoaded(
        filter: LibraryFilter.all,
        playlists: playlists,
        albums: albums,
        artists: artists,
        likedSongs: likedSongs,
        recentlyPlayed: allSongs.take(5).toList(),
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
