import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/notification_artwork.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../data/services/audio_player_service.dart' show AudioQueueItem, TrackMetadata;
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
    // While a new song is loading, position/duration/completed events still
    // belong to the previously loaded source, so they must not touch state.
    _positionSubscription = _repository.positionStream.listen((position) {
      if (_loading) return;
      emit(state.copyWith(position: position));
    });
    _durationSubscription = _repository.durationStream.listen((duration) {
      if (_loading) return;
      emit(state.copyWith(duration: duration));
    });
    _statusSubscription = _repository.statusStream.listen((status) {
      if (_loading && status == PlaybackStatus.completed) return;
      emit(state.copyWith(status: status));
      if (status == PlaybackStatus.completed) {
        _onSongCompleted();
      }
    });
    _currentIndexSubscription = _repository.currentIndexStream.listen(_onCurrentIndexChanged);
  }

  final PlayerRepository _repository;
  final Future<void> Function(String songId)? _onPlaybackStarted;
  final math.Random _random = math.Random();

  /// Longest a selection waits for notification artwork before starting
  /// playback without it (extraction continues and warms the cache).
  static const _artworkBudget = Duration(milliseconds: 700);

  // The latest requested queue/index while a load is in flight. The visible
  // state only switches to it once the engine has accepted the new source.
  List<SongEntity> _targetQueue = const [];
  int _targetIndex = -1;
  List<SongEntity> get _queue => _loading ? _targetQueue : state.queue;
  int get _index => _loading ? _targetIndex : state.currentIndex;

  /// Generation token for the latest selection. Every await in
  /// [_play] re-checks it so a superseded request can never
  /// start playback or write state after a newer one began.
  int _requestId = 0;
  bool _loading = false;

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<PlaybackStatus> _statusSubscription;
  late final StreamSubscription<int?> _currentIndexSubscription;

  Future<void> playQueue(List<SongEntity> songs, {int startIndex = 0}) =>
      _play(songs, startIndex);

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
    final queue = _queue;
    final current = _index;
    if (queue.isEmpty) return;

    int? nextIndex;

    if (state.isShuffle && queue.length > 1) {
      int candidate;
      do {
        candidate = _random.nextInt(queue.length);
      } while (candidate == current);
      nextIndex = candidate;
    } else {
      final isLast = current >= queue.length - 1;
      if (!isLast) {
        nextIndex = current + 1;
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

    await _play(queue, nextIndex);
  }

  Future<void> skipPrevious() async {
    final queue = _queue;
    if (queue.isEmpty) return;

    if (!_loading && state.position > const Duration(seconds: 3)) {
      await _repository.seek(Duration.zero);
      return;
    }

    final current = _index;
    await _play(queue, current <= 0 ? queue.length - 1 : current - 1);
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.isShuffle;
    emit(state.copyWith(isShuffle: enabled));
    try {
      await _repository.setShuffleEnabled(enabled);
    } catch (e) {
      emit(state.copyWith(isShuffle: !enabled, errorMessage: e.toString()));
    }
  }

  Future<void> cycleRepeatMode() async {
    final previous = state.repeatMode;
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeatMode: next));
    try {
      await _repository.setRepeatMode(next);
    } catch (e) {
      emit(state.copyWith(repeatMode: previous, errorMessage: e.toString()));
    }
  }

  Future<void> _onSongCompleted() async {
    if (state.repeatMode == RepeatMode.one) {
      await _play(state.queue, state.currentIndex);
    } else {
      await skipNext(auto: true);
    }
  }

  void _onCurrentIndexChanged(int? index) {
    if (_loading ||
        index == null ||
        index < 0 ||
        index >= state.queue.length ||
        index == state.currentIndex) {
      return;
    }

    emit(state.copyWith(currentIndex: index, position: Duration.zero));
    final song = state.currentSong;
    final onPlaybackStarted = _onPlaybackStarted;
    if (song != null && onPlaybackStarted != null) {
      unawaited(onPlaybackStarted(song.id));
    }
  }

  Future<void> _play(List<SongEntity> queue, int index) async {
    if (index < 0 || index >= queue.length) return;

    // Newest selection wins: this invalidates every earlier in-flight request.
    final requestId = ++_requestId;
    bool isStale() => requestId != _requestId;
    _loading = true;
    _targetQueue = queue;
    _targetIndex = index;
    final song = queue[index];
    // "Now playing" keeps showing what is actually playing until the engine
    // accepts the new source; only the status reflects the pending load.
    emit(state.copyWith(status: PlaybackStatus.loading));

    try {
      final artUri = await NotificationArtwork.forSong(song.artworkId, isCurrent: () => !isStale())
          .timeout(_artworkBudget, onTimeout: () => null);
      if (isStale()) return;
      final audioQueue = queue.indexed.map((entry) {
        final (queueIndex, queuedSong) = entry;
        return AudioQueueItem(
          url: queuedSong.audioUrl,
          metadata: TrackMetadata(
            id: queuedSong.id,
            title: queuedSong.title,
            artist: queuedSong.artist,
            album: queuedSong.album,
            artUri: queueIndex == index ? artUri : null,
          ),
        );
      }).toList(growable: false);
      await _repository.loadQueueAndPlay(
        queue: audioQueue,
        initialIndex: index,
        shuffleEnabled: state.isShuffle,
        repeatMode: state.repeatMode,
      );
      if (isStale()) return;
      // Source accepted and playing: now the UI may show the new song.
      _loading = false;
      emit(state.copyWith(
        queue: queue,
        currentIndex: index,
        position: Duration.zero,
        duration: song.duration,
      ));
      await _onPlaybackStarted?.call(song.id);
    } catch (e) {
      // A superseded request's failure (e.g. "Loading interrupted") is expected.
      if (isStale()) return;
      _loading = false;
      emit(state.copyWith(status: PlaybackStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _statusSubscription.cancel();
    await _currentIndexSubscription.cancel();
    return super.close();
  }
}
