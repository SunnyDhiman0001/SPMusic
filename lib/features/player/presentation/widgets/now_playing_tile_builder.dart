import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';

typedef NowPlayingWidgetBuilder = Widget Function(
  BuildContext context,
  bool isCurrent,
  bool isPlaying,
);

/// Tells a song row whether it is the current song and whether it is
/// audibly playing. Each row selects only its own two flags, so starting a
/// new song rebuilds just the old and new rows, not the whole list.
class NowPlayingTileBuilder extends StatelessWidget {
  const NowPlayingTileBuilder({required this.songId, required this.builder, super.key});

  final String songId;
  final NowPlayingWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlayerCubit, PlayerState, (bool, bool)>(
      selector: (state) {
        final isCurrent = state.currentSong?.id == songId;
        return (isCurrent, isCurrent && state.isPlaying);
      },
      builder: (context, flags) => builder(context, flags.$1, flags.$2),
    );
  }
}
