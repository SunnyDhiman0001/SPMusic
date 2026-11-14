import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/entrance.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../bloc/recently_played_cubit.dart';

/// Home "Recently Played" row. Hidden until something has been played.
class RecentlyPlayedSection extends StatelessWidget {
  const RecentlyPlayedSection({super.key});

  static const double _cardSize = 112;
  static const double _cardPadding = 6;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentlyPlayedCubit, List<SongEntity>>(
      builder: (context, songs) {
        if (songs.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Recently Played', style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: _cardSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: songs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Entrance(
                    index: index,
                    child: Semantics(
                      button: true,
                      label: 'Play ${song.title}',
                      child: Pressable(
                        child: GestureDetector(
                          key: ValueKey('recent-${song.id}'),
                          onTap: () =>
                              context.read<PlayerCubit>().playQueue(songs, startIndex: index),
                          child: SizedBox(
                            width: _cardSize,
                            height: _cardSize,
                            child: GlassCard(
                              padding: const EdgeInsets.all(_cardPadding),
                              child: LocalArtwork(
                                kind: ArtworkKind.song,
                                id: song.artworkId,
                                size: _cardSize - _cardPadding * 2,
                                borderRadius: AppRadius.mdRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }
}
