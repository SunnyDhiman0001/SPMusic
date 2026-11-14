import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../music/domain/entities/song_entity.dart';
import '../../../music/domain/repositories/music_repository.dart';

/// The Home "Recently Played" row: the last [maxItems] unique songs, newest
/// first. Order, de-duplication and persistence come from the existing
/// recently-played storage (SharedPreferences, behind [MusicRepository]);
/// this cubit only caps the list and keeps the UI in sync.
///
/// Registered as a singleton so playback (which reports song starts through
/// [onSongStarted]) and the Home screen share one instance.
class RecentlyPlayedCubit extends Cubit<List<SongEntity>> {
  RecentlyPlayedCubit(this._repository, {Stream<void>? libraryChanges}) : super(const []) {
    _changesSubscription = libraryChanges?.listen((_) => unawaited(load()));
  }

  static const int maxItems = 10;

  final MusicRepository _repository;
  StreamSubscription<void>? _changesSubscription;

  Future<void> load() async {
    try {
      final songs = await _repository.getRecentlyPlayed();
      emit(songs.take(maxItems).toList(growable: false));
    } catch (_) {
      // Keep showing the last good list.
    }
  }

  /// Passed to `PlayerCubit(onPlaybackStarted: ...)`: persists the play, then
  /// refreshes the row.
  Future<void> onSongStarted(String songId) async {
    await _repository.recordPlayed(songId);
    await load();
  }

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    return super.close();
  }
}
