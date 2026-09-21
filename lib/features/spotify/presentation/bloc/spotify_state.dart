import 'package:equatable/equatable.dart';

import '../../domain/entities/spotify_playlist_entity.dart';
import '../../domain/entities/spotify_track_entity.dart';
import '../../domain/entities/spotify_user_entity.dart';

sealed class SpotifyState extends Equatable {
  const SpotifyState();

  @override
  List<Object?> get props => [];
}

class SpotifyDisconnected extends SpotifyState {
  const SpotifyDisconnected();
}

class SpotifyConnecting extends SpotifyState {
  const SpotifyConnecting();
}

class SpotifyConnectedIdle extends SpotifyState {
  const SpotifyConnectedIdle(this.user);

  final SpotifyUserEntity user;

  @override
  List<Object?> get props => [user];
}

class SpotifySearchResults extends SpotifyState {
  const SpotifySearchResults(this.user, this.tracks);

  final SpotifyUserEntity user;
  final List<SpotifyTrackEntity> tracks;

  @override
  List<Object?> get props => [user, tracks];
}

class SpotifyPlaylistCreating extends SpotifyState {
  const SpotifyPlaylistCreating(this.tracks);

  final List<SpotifyTrackEntity> tracks;

  @override
  List<Object?> get props => [tracks];
}

class SpotifyPlaylistReady extends SpotifyState {
  const SpotifyPlaylistReady(this.playlist);

  final SpotifyPlaylistEntity playlist;

  @override
  List<Object?> get props => [playlist];
}

class SpotifyError extends SpotifyState {
  const SpotifyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
