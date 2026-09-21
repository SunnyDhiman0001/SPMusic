import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_play_button.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlayerCubit, PlayerState, (SongEntity?, bool)>(
      selector: (state) => (state.currentSong, state.isPlaying),
      builder: (context, selected) {
        final (song, isPlaying) = selected;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/player'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'player-artwork-${song.id}',
                  child: LocalArtwork(
                    kind: ArtworkKind.song,
                    id: song.artworkId,
                    size: 44,
                    borderRadius: AppRadius.smRadius,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AnimatedPlayButton(
                  isPlaying: isPlaying,
                  onPressed: () => context.read<PlayerCubit>().togglePlayPause(),
                  size: 40,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => context.read<PlayerCubit>().skipNext(),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.3, end: 0, duration: 250.ms).fadeIn(duration: 250.ms);
      },
    );
  }
}
