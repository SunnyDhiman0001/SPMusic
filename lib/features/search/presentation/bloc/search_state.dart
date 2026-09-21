import 'package:equatable/equatable.dart';
import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';

class SearchResults extends Equatable {
  const SearchResults({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.playlists,
  });

  final List<SongEntity> songs;
  final List<ArtistEntity> artists;
  final List<AlbumEntity> albums;
  final List<PlaylistEntity> playlists;

  bool get isEmpty => songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;

  @override
  List<Object?> get props => [songs, artists, albums, playlists];
}

sealed class SearchState extends Equatable {
  const SearchState({required this.recentSearches});

  final List<String> recentSearches;

  @override
  List<Object?> get props => [recentSearches];
}

class SearchIdle extends SearchState {
  const SearchIdle({super.recentSearches = const []});
}

class SearchLoading extends SearchState {
  const SearchLoading({required super.recentSearches});
}

class SearchLoaded extends SearchState {
  const SearchLoaded({required this.results, required super.recentSearches});

  final SearchResults results;

  @override
  List<Object?> get props => [results, recentSearches];
}

class SearchError extends SearchState {
  const SearchError({required this.message, required super.recentSearches});

  final String message;

  @override
  List<Object?> get props => [message, recentSearches];
}
