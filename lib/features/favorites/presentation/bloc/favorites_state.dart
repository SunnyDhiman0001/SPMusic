import 'package:equatable/equatable.dart';
import '../../../music/domain/entities/song_entity.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({required this.songs, required this.favoriteSongIds});

  final List<SongEntity> songs;
  final Set<String> favoriteSongIds;

  bool isFavorite(String songId) => favoriteSongIds.contains(songId);

  @override
  List<Object?> get props => [songs, favoriteSongIds];
}

class FavoritesError extends FavoritesState {
  const FavoritesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
