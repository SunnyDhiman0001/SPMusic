import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';

/// The up-next queue, read straight from [PlayerCubit] — there is no
/// separate "queue" state to keep in sync, this just renders what's
/// already there. Tapping a song jumps playback to it.
class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final queue = state.queue;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant,
                  borderRadius: AppRadius.roundRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Queue', style: theme.textTheme.headlineMedium),
                    Text('${queue.length} songs', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: queue.isEmpty
                    ? const Center(child: Text('Queue is empty'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final isCurrent = index == state.currentIndex;
                          return SearchSongTile(
                            song: queue[index],
                            leadingBorderRadius: AppRadius.smRadius,
                            selected: isCurrent,
                            selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                            trailing: isCurrent
                                ? Icon(LucideIcons.audio_waveform, color: theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              context.read<PlayerCubit>().playQueue(queue, startIndex: index);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
