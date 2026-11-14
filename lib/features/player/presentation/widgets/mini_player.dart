import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_play_button.dart';
import '../../../../core/widgets/glass_card.dart';
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

        final decor = context.decor;

        return GestureDetector(
          onTap: () => context.push('/player'),
          child: GlassCard(
            blur: true,
            elevated: true,
            radius: BorderRadius.circular(32),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _TopProgress(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'player-artwork-${song.id}',
                        child: LocalArtwork(
                          kind: ArtworkKind.song,
                          id: song.artworkId,
                          size: 48,
                          borderRadius: AppRadius.roundRadius,
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
                        color: decor.miniPlayFill,
                        iconColor: decor.miniPlayIcon,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.skip_forward),
                        onPressed: () => context.read<PlayerCubit>().skipNext(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.3, end: 0, duration: 250.ms).fadeIn(duration: 250.ms);
      },
    );
  }
}

/// 2px playback progress line along the top edge of the glass card.
class _TopProgress extends StatelessWidget {
  const _TopProgress();

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    return BlocSelector<PlayerCubit, PlayerState, double>(
      selector: (state) {
        final total = state.duration?.inMilliseconds ?? 0;
        if (total <= 0) return 0;
        return (state.position.inMilliseconds / total).clamp(0.0, 1.0);
      },
      builder: (context, progress) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: SizedBox(
          key: const ValueKey('mini-player-progress'),
          height: 2,
          child: ColoredBox(
            color: decor.progressInactive,
            child: Align(
              alignment: Alignment.centerLeft,
              // heightFactor: 1 matters: a childless ColoredBox under loose
              // constraints would otherwise collapse to zero height.
              child: FractionallySizedBox(
                widthFactor: progress,
                heightFactor: 1,
                child: ColoredBox(color: decor.progressActive),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
