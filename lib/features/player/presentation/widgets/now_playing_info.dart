import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../music/domain/entities/song_entity.dart';

class NowPlayingInfo extends StatelessWidget {
  const NowPlayingInfo({
    required this.song,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  final SongEntity song;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onDoubleTap: onToggleFavorite,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FavoriteButton(isFavorite: isFavorite, onTap: onToggleFavorite),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
