import 'package:equatable/equatable.dart';

import '../../../music/domain/entities/song_entity.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/repeat_mode.dart';

class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlaybackStatus.idle,
    this.queue = const [],
    this.currentIndex = -1,
    this.position = Duration.zero,
    this.duration,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.errorMessage,
  });

  final PlaybackStatus status;
  final List<SongEntity> queue;
  final int currentIndex;
  final Duration position;
  final Duration? duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final String? errorMessage;

  SongEntity? get currentSong =>
      currentIndex >= 0 && currentIndex < queue.length ? queue[currentIndex] : null;

  bool get isPlaying => status == PlaybackStatus.playing;

  PlayerState copyWith({
    PlaybackStatus? status,
    List<SongEntity>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    String? errorMessage,
  }) {
    return PlayerState(
      status: status ?? this.status,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        queue,
        currentIndex,
        position,
        duration,
        isShuffle,
        repeatMode,
        errorMessage,
      ];
}
