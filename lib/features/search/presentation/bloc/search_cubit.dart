import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../music/domain/repositories/music_repository.dart';
import 'search_state.dart';

const _maxRecentSearches = 8;

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchIdle());

  final MusicRepository _repository;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(SearchIdle(recentSearches: state.recentSearches));
      return;
    }

    emit(SearchLoading(recentSearches: state.recentSearches));
    try {
      final results = await Future.wait([
        _repository.searchSongs(trimmed),
        _repository.searchArtists(trimmed),
        _repository.searchAlbums(trimmed),
        _repository.searchPlaylists(trimmed),
      ]);

      emit(SearchLoaded(
        results: SearchResults(
          songs: results[0] as List<SongEntity>,
          artists: results[1] as List<ArtistEntity>,
          albums: results[2] as List<AlbumEntity>,
          playlists: results[3] as List<PlaylistEntity>,
        ),
        recentSearches: _withRecent(trimmed),
      ));
    } catch (e) {
      emit(SearchError(message: e.toString(), recentSearches: state.recentSearches));
    }
  }

  void clearRecentSearches() {
    final current = state;
    switch (current) {
      case SearchIdle():
        emit(const SearchIdle(recentSearches: []));
      case SearchLoading():
        emit(const SearchLoading(recentSearches: []));
      case SearchLoaded():
        emit(SearchLoaded(results: current.results, recentSearches: const []));
      case SearchError():
        emit(SearchError(message: current.message, recentSearches: const []));
    }
  }

  List<String> _withRecent(String query) {
    final updated = [
      query,
      ...state.recentSearches.where((s) => s.toLowerCase() != query.toLowerCase()),
    ];
    return updated.take(_maxRecentSearches).toList();
  }
}
