import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../music/domain/repositories/music_repository.dart';
import 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit(this._repository) : super(const PlaylistLoading());

  final MusicRepository _repository;

  Future<void> loadPlaylist(String id) async {
    emit(const PlaylistLoading());
    try {
      final playlist = await _repository.getPlaylistById(id);
      final songs = await _repository.getSongsByIds(playlist.songIds);
      emit(PlaylistLoaded(playlist: playlist, songs: songs));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }
}
