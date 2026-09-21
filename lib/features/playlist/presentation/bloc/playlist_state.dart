import 'package:equatable/equatable.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
}

class PlaylistLoaded extends PlaylistState {
  const PlaylistLoaded({required this.playlist, required this.songs});

  final PlaylistEntity playlist;
  final List<SongEntity> songs;

  @override
  List<Object?> get props => [playlist, songs];
}

class PlaylistError extends PlaylistState {
  const PlaylistError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
