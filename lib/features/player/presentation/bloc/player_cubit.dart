import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/notification_artwork.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../data/services/audio_player_service.dart' show TrackMetadata;
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/repositories/player_repository.dart';
import 'player_state.dart';

/// Global playback session: owns the queue, shuffle/repeat state and the
/// currently playing song. Registered as a singleton so the mini-player and
/// full-player screens (built later) share the same instance.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._repository, {Future<void> Function(String songId)? onPlaybackStarted})
      : _onPlaybackStarted = onPlaybackStarted,
        super(const PlayerState()) {
    _positionSubscription = _repository.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });
    _durationSubscription = _repository.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration));
    });
    _statusSubscription = _repository.statusStream.listen((status) {
      emit(state.copyWith(status: status));
      if (status == PlaybackStatus.completed) {
        _onSongCompleted();
      }
    });
  }

  final PlayerRepository _repository;
  final Future<void> Function(String songId)? _onPlaybackStarted;
  final math.Random _random = math.Random();

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<PlaybackStatus> _statusSubscription;

  Future<void> playQueue(List<SongEntity> songs, {int startIndex = 0}) async {
    emit(state.copyWith(queue: songs, currentIndex: startIndex));
    await _playCurrentIndex();
  }

  Future<void> playSingle(SongEntity song) => playQueue([song]);

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _repository.pause();
    } else if (state.currentSong != null) {
      await _repository.resume();
    }
  }

  Future<void> seek(Duration position) => _repository.seek(position);

  Future<void> skipNext({bool auto = false}) async {
    final queue = state.queue;
    if (queue.isEmpty) return;

    int? nextIndex;

    if (state.isShuffle && queue.length > 1) {
      int candidate;
      do {
        candidate = _random.nextInt(queue.length);
      } while (candidate == state.currentIndex);
      nextIndex = candidate;
    } else {
      final isLast = state.currentIndex >= queue.length - 1;
      if (!isLast) {
        nextIndex = state.currentIndex + 1;
      } else if (!auto) {
        // Explicit user tap always wraps around, regardless of repeat mode.
        nextIndex = 0;
      } else if (state.repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        // auto-advance at the end of the queue with repeat off: nowhere to go.
        nextIndex = null;
      }
    }

    if (nextIndex == null) return;

    emit(state.copyWith(currentIndex: nextIndex));
    await _playCurrentIndex();
  }

  Future<void> skipPrevious() async {
    if (state.queue.isEmpty) return;

    if (state.position > const Duration(seconds: 3)) {
      await _repository.seek(Duration.zero);
      return;
    }

    final previousIndex =
        state.currentIndex <= 0 ? state.queue.length - 1 : state.currentIndex - 1;
    emit(state.copyWith(currentIndex: previousIndex));
    await _playCurrentIndex();
  }

  void toggleShuffle() => emit(state.copyWith(isShuffle: !state.isShuffle));

  void cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeatMode: next));
  }

  Future<void> _onSongCompleted() async {
    if (state.repeatMode == RepeatMode.one) {
      await _playCurrentIndex();
    } else {
      await skipNext(auto: true);
    }
  }

  Future<void> _playCurrentIndex() async {
    final index = state.currentIndex;
    if (index < 0 || index >= state.queue.length) return;

    emit(state.copyWith(currentIndex: index, position: Duration.zero));
    final song = state.currentSong;
    if (song == null) return;

    try {
      final artUri = await NotificationArtwork.forSong(song.artworkId);
      await _repository.loadAndPlay(
        song.audioUrl,
        TrackMetadata(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          artUri: artUri,
        ),
      );
      await _onPlaybackStarted?.call(song.id);
    } catch (e) {
      emit(state.copyWith(status: PlaybackStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _statusSubscription.cancel();
    return super.close();
  }
}
