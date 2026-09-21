import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../music/domain/repositories/music_repository.dart';
import 'favorites_state.dart';

/// Single source of truth for which songs are favorited.
///
/// Registered as an app-wide singleton (see injector.dart) and provided at
/// the app root, so Home, Favourites, Playlist and the Now Playing screen
/// all read and mutate the exact same state — toggling a favorite anywhere
/// is reflected everywhere immediately, with no per-screen state to fall
/// out of sync.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesLoading());

  final MusicRepository _repository;

  Future<void> refresh() => load();

  Future<void> load() async {
    emit(const FavoritesLoading());
    try {
      final favoriteSongs = await _repository.getFavoriteSongs();
      emit(
        FavoritesLoaded(
          songs: favoriteSongs,
          favoriteSongIds: favoriteSongs.map((song) => song.id).toSet(),
        ),
      );
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  bool isFavorite(String songId) {
    final currentState = state;
    return currentState is FavoritesLoaded && currentState.isFavorite(songId);
  }

  Future<void> toggleFavorite(String songId) async {
    await _repository.toggleFavorite(songId);
    await load();
  }
}
