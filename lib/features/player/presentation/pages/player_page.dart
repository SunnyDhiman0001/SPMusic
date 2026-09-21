import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import '../widgets/player_body.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.darkBackgroundGradient,
          ),
        ),
        child: SafeArea(
          child: BlocSelector<PlayerCubit, PlayerState, SongEntity?>(
            selector: (state) => state.currentSong,
            builder: (context, song) {
              return Column(
                children: [
                  const _PlayerAppBar(),
                  if (song == null)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Nothing playing',
                          style: TextStyle(color: AppColors.textPrimaryDark),
                        ),
                      ),
                    )
                  else
                    Expanded(child: PlayerBody(song: song)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlayerAppBar extends StatelessWidget {
  const _PlayerAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimaryDark),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
