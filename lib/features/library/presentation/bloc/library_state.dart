import 'package:equatable/equatable.dart';
import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';

enum LibraryFilter { all, playlists, songs, albums, artists }

sealed class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

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

class LibraryPermissionDenied extends LibraryState {
  const LibraryPermissionDenied({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  List<Object?> get props => [permanentlyDenied];
}

class LibraryError extends LibraryState {
  const LibraryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
