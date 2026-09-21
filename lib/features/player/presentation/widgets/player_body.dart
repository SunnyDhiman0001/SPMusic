import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/music_progress_bar.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import 'now_playing_info.dart';
import 'player_bottom_actions.dart';
import 'player_controls.dart';
import 'rotating_artwork.dart';

class PlayerBody extends StatelessWidget {
  const PlayerBody({required this.song, super.key});

  final SongEntity song;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BlocSelector<PlayerCubit, PlayerState, bool>(
            selector: (state) => state.isPlaying,
            builder: (context, isPlaying) => RotatingArtwork(
              artworkId: song.artworkId,
              heroTag: 'player-artwork-${song.id}',
              isPlaying: isPlaying,
            ),
          ),
          BlocSelector<FavoritesCubit, FavoritesState, bool>(
            selector: (state) => state is FavoritesLoaded && state.isFavorite(song.id),
            builder: (context, isFavorite) => NowPlayingInfo(
              song: song,
              isFavorite: isFavorite,
              onToggleFavorite: () => context.read<FavoritesCubit>().toggleFavorite(song.id),
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
