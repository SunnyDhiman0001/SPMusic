import 'dart:async';

import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../data/services/audio_player_service.dart';
import 'player_cubit.dart';

/// Connects the system media notification to the app's cubits: button taps
/// are routed to them, and their state (shuffle, favourite) is pushed back so
/// the notification icons always match the in-app player.
class MediaSessionBinder implements MediaSessionDelegate {
  MediaSessionBinder({
    required this.session,
    required this.player,
    required this.favorites,
  });

  final MediaSessionService session;
  final PlayerCubit player;
  final FavoritesCubit favorites;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _lastFavorite = false;

  Future<void> start() async {
    await session.initMediaSession(this);
    _subscriptions.addAll([
      player.stream.listen((_) => _push()),
      // Ignore the transient loading state emitted while a toggle reloads,
      // otherwise the heart would flicker off and on.
      favorites.stream.where((s) => s is FavoritesLoaded).listen((_) => _push()),
    ]);
    _push();
  }

  void _push() {
    final song = player.state.currentSong;
    if (song == null) {
      _lastFavorite = false;
    } else if (favorites.state is FavoritesLoaded) {
      _lastFavorite = favorites.isFavorite(song.id);
    }
    session.updateSession(isShuffle: player.state.isShuffle, isFavorite: _lastFavorite);
  }

  @override
  Future<void> onSkipNext() => player.skipNext();

  @override
  Future<void> onSkipPrevious() => player.skipPrevious();

  @override
  Future<void> onToggleShuffle() => player.toggleShuffle();

  @override
  Future<void> onToggleFavorite() async {
    final song = player.state.currentSong;
    if (song == null) return;
    await favorites.toggleFavorite(song.id);
  }

  Future<void> dispose() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
  }
}
