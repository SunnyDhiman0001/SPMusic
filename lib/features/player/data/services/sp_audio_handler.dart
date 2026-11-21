import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart' as ja;

import 'audio_player_service.dart' show MediaSessionDelegate;

/// The app's one media session: drives the system notification and lock
/// screen player (title, artwork, seek bar, prev / play / next, plus custom
/// like and shuffle buttons) from the shared [ja.AudioPlayer].
///
/// Queue, shuffle and favourites logic lives in the player cubit; skip and
/// custom buttons are forwarded through [delegate] so the notification can
/// never disagree with the in-app player.
class SpAudioHandler extends BaseAudioHandler with SeekHandler {
  SpAudioHandler(this._player) {
    _player.playbackEventStream.listen((_) => _broadcast(), onError: (Object _) => _broadcast());
    _player.playerStateStream.listen((_) => _broadcast());
    _player.sequenceStateStream.listen(_onSequenceChanged);
    _player.durationStream.listen(_onDuration);
  }

  static const _toggleFavorite = 'toggleFavorite';
  static const _toggleShuffle = 'toggleShuffle';

  static final _favoriteOff = MediaControl.custom(
    androidIcon: 'drawable/ic_notif_favorite_border',
    label: 'Like',
    name: _toggleFavorite,
  );
  static final _favoriteOn = MediaControl.custom(
    androidIcon: 'drawable/ic_notif_favorite',
    label: 'Unlike',
    name: _toggleFavorite,
  );
  static final _shuffleOff = MediaControl.custom(
    androidIcon: 'drawable/ic_notif_shuffle',
    label: 'Shuffle on',
    name: _toggleShuffle,
  );
  static final _shuffleOn = MediaControl.custom(
    androidIcon: 'drawable/ic_notif_shuffle_on',
    label: 'Shuffle off',
    name: _toggleShuffle,
  );

  final ja.AudioPlayer _player;

  MediaSessionDelegate? delegate;
  bool _isShuffle = false;
  bool _isFavorite = false;

  void updateButtons({required bool isShuffle, required bool isFavorite}) {
    if (isShuffle == _isShuffle && isFavorite == _isFavorite) return;
    _isShuffle = isShuffle;
    _isFavorite = isFavorite;
    _broadcast();
  }

  void _onSequenceChanged(ja.SequenceState? state) {
    final tag = state?.currentSource?.tag;
    if (tag is! MediaItem) return;
    mediaItem.add(tag.duration == null ? tag.copyWith(duration: _player.duration) : tag);
  }

  void _onDuration(Duration? duration) {
    final item = mediaItem.value;
    if (item == null || duration == null || item.duration == duration) return;
    mediaItem.add(item.copyWith(duration: duration));
  }

  void _broadcast() {
    final playing = _player.playing;
    playbackState.add(
      PlaybackState(
        // Android 13+ lays custom actions out around prev / play / next
        // (like on the left, shuffle on the right). Older versions only show
        // the standard three in the notification.
        controls: [
          _isFavorite ? _favoriteOn : _favoriteOff,
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          _isShuffle ? _shuffleOn : _shuffleOff,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToPrevious,
          MediaAction.skipToNext,
        },
        // Indexes into the non-custom controls only (prev, play, next).
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (_player.processingState) {
          ja.ProcessingState.idle => AudioProcessingState.idle,
          ja.ProcessingState.loading => AudioProcessingState.loading,
          ja.ProcessingState.buffering => AudioProcessingState.buffering,
          ja.ProcessingState.ready => AudioProcessingState.ready,
          ja.ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  @override
  Future<void> play() async {
    // just_audio's play() only completes when playback pauses or ends.
    unawaited(_player.play().catchError((Object _) {}));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final d = delegate;
    if (d != null) return d.onSkipNext();
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    final d = delegate;
    if (d != null) return d.onSkipPrevious();
    await _player.seekToPrevious();
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case _toggleFavorite:
        await delegate?.onToggleFavorite();
      case _toggleShuffle:
        await delegate?.onToggleShuffle();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _broadcast();
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!_player.playing) await stop();
  }
}
