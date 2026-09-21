import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/animated_play_button.dart';
import '../../domain/entities/repeat_mode.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';

typedef _ControlsSlice = (bool isShuffle, bool isPlaying, RepeatMode repeatMode);

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    required this.onToggleShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onCycleRepeat,
    super.key,
  });

  final VoidCallback onToggleShuffle;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onCycleRepeat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface;

    return BlocSelector<PlayerCubit, PlayerState, _ControlsSlice>(
      selector: (state) => (state.isShuffle, state.isPlaying, state.repeatMode),
      builder: (context, slice) {
        final (isShuffle, isPlaying, repeatMode) = slice;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: isShuffle ? activeColor : inactiveColor,
              ),
              onPressed: onToggleShuffle,
            ),
            IconButton(
              icon: Icon(Icons.skip_previous, color: inactiveColor),
              iconSize: 36,
              onPressed: onPrevious,
            ),
            AnimatedPlayButton(
              isPlaying: isPlaying,
              onPressed: onPlayPause,
              size: 72,
              iconSize: 32,
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: inactiveColor),
              iconSize: 36,
              onPressed: onNext,
            ),
            IconButton(
              icon: Icon(
                repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
                color: repeatMode == RepeatMode.off ? inactiveColor : activeColor,
              ),
              onPressed: onCycleRepeat,
            ),
          ],
        );
      },
    );
  }
}
