import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/spotify_repository.dart';
import 'spotify_state.dart';

class SpotifyCubit extends Cubit<SpotifyState> {
  SpotifyCubit(this._repository) : super(const SpotifyDisconnected());

  final SpotifyRepository _repository;

  Future<void> checkConnection() async {
    if (await _repository.isConnected()) {
      try {
        emit(SpotifyConnectedIdle(await _repository.getCurrentUser()));
      } catch (e) {
        emit(SpotifyError(e.toString()));
      }
    } else {
      emit(const SpotifyDisconnected());
    }
  }

  Future<void> connectAndShowSearch() async {
    emit(const SpotifyConnecting());
    try {
      await _repository.connect();
      emit(SpotifyConnectedIdle(await _repository.getCurrentUser()));
    } catch (e) {
      emit(SpotifyError(e.toString()));
    }
  }

  Future<void> search(String query) async {
    final user = switch (state) {
      SpotifyConnectedIdle(:final user) => user,
      SpotifySearchResults(:final user) => user,
      _ => null,
    };
    if (user == null) return;

    if (query.trim().isEmpty) {
      emit(SpotifyConnectedIdle(user));
      return;
    }
    try {
      emit(SpotifySearchResults(user, await _repository.searchTracks(query)));
    } catch (e) {
      emit(SpotifyError(e.toString()));
    }
  }

  Future<void> createPlaylist() async {
    final currentState = state;
    if (currentState is! SpotifySearchResults) return;
    final tracks = currentState.tracks.take(10).toList();

    emit(SpotifyPlaylistCreating(tracks));
    try {
      final playlist = await _repository.createPlaylistFromTracks(
        name: 'My Search Playlist',
        description: 'Created from spmusic',
        trackUris: tracks.map((t) => t.uri).toList(),
      );
      emit(SpotifyPlaylistReady(playlist));
    } catch (e) {
      emit(SpotifyError(e.toString()));
    }
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
    emit(const SpotifyDisconnected());
  }
}
