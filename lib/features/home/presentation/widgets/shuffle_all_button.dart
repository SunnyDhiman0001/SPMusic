import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/widgets/glow_button.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../utils/shuffle_all.dart';

/// Home "shuffle all" button. It is a way to *start* playing, so it only
/// exists while nothing is loaded; once a song is playing (or paused) the
/// mini-player takes over and the button is removed.
class ShuffleAllButton extends StatelessWidget {
  const ShuffleAllButton({required this.songs, super.key});

  final List<SongEntity> songs;

  @override
  Widget build(BuildContext context) {
    final hasSong = context.select((PlayerCubit cubit) => cubit.state.currentSong != null);
    // Scales/fades in on first show and out when playback starts.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: hasSong
          ? const SizedBox.shrink(key: ValueKey('shuffle-hidden'))
          : GlowButton(
              key: const ValueKey('shuffle-visible'),
              icon: LucideIcons.play,
              tooltip: 'Shuffle play',
              onPressed: () => shuffleAll(context.read<PlayerCubit>(), songs),
            ),
    );
  }
}
