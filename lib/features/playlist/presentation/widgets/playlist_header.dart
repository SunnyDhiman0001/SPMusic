import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../music/domain/entities/playlist_entity.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({
    required this.playlist,
    required this.songCount,
    required this.onPlay,
    required this.onShuffle,
    super.key,
  });

  final PlaylistEntity playlist;
  final int songCount;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadius.lgRadius,
            child: CachedNetworkImage(
              imageUrl: playlist.coverUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(playlist.name, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(playlist.description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$songCount songs · By ${playlist.creator}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onShuffle,
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
