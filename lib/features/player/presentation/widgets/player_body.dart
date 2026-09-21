import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/music_progress_bar.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../music/domain/repositories/music_repository.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import 'now_playing_info.dart';
import 'player_bottom_actions.dart';
import 'player_controls.dart';
import 'rotating_artwork.dart';

class PlayerBody extends StatefulWidget {
  const PlayerBody({required this.song, super.key});

  final SongEntity song;

  @override
  State<PlayerBody> createState() => _PlayerBodyState();
}

class _PlayerBodyState extends State<PlayerBody> {
  late String _songId = widget.song.id;
  late final ValueNotifier<bool> _isFavorite = ValueNotifier<bool>(widget.song.isFavorite);

  @override
  void didUpdateWidget(covariant PlayerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.song.id != _songId) {
      _songId = widget.song.id;
      _isFavorite.value = widget.song.isFavorite;
    }
  }

  @override
  void dispose() {
    _isFavorite.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    _isFavorite.value = !_isFavorite.value;
    await sl<MusicRepository>().toggleFavorite(widget.song.id);
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final cubit = context.read<PlayerCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BlocSelector<PlayerCubit, PlayerState, bool>(
            selector: (state) => state.isPlaying,
            builder: (context, isPlaying) => RotatingArtwork(
              imageUrl: song.artworkUrl,
              heroTag: 'player-artwork-${song.id}',
              isPlaying: isPlaying,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isFavorite,
            builder: (context, isFavorite, _) => NowPlayingInfo(
              song: song,
              isFavorite: isFavorite,
              onToggleFavorite: _toggleFavorite,
            ),
          ),
          BlocSelector<PlayerCubit, PlayerState, (Duration, Duration)>(
            selector: (state) => (state.position, state.duration ?? Duration.zero),
            builder: (context, positionAndDuration) {
              final (position, duration) = positionAndDuration;
              return MusicProgressBar(
                position: position,
                duration: duration,
                onSeek: cubit.seek,
              );
            },
          ),
          PlayerControls(
            onToggleShuffle: cubit.toggleShuffle,
            onPrevious: cubit.skipPrevious,
            onPlayPause: cubit.togglePlayPause,
            onNext: cubit.skipNext,
            onCycleRepeat: cubit.cycleRepeatMode,
          ),
          const PlayerBottomActions(),
        ],
      ),
    );
  }
}
