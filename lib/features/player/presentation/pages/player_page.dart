import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import '../widgets/player_body.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocSelector<PlayerCubit, PlayerState, SongEntity?>(
        selector: (state) => state.currentSong,
        builder: (context, song) {
          return Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.darkBackgroundGradient,
                    ),
                  ),
                ),
              ),
              if (song != null)
                Positioned.fill(
                  child: _ArtworkBackdrop(artworkId: song.artworkId),
                ),
              SafeArea(
                child: Column(
                  children: [
                    const _PlayerAppBar(),
                    if (song == null)
                      Expanded(
                        child: Center(
                          child: Text(
                            'Nothing playing',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      Expanded(child: PlayerBody(song: song)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen ambient backdrop: the album cover heavily blurred and scaled
/// up, crossfading when the song changes, with a dark scrim so text and
/// controls stay readable, plus a soft accent glow behind the artwork.
class _ArtworkBackdrop extends StatelessWidget {
  const _ArtworkBackdrop({required this.artworkId});

  final int artworkId;

  @override
  Widget build(BuildContext context) {
    const base = AppColors.obsidian;
    final size = MediaQuery.sizeOf(context);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeOut,
            child: KeyedSubtree(
              key: ValueKey(artworkId),
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.clamp),
                  child: Transform.scale(
                    scale: 1.6,
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: LocalArtwork(
                          kind: ArtworkKind.song,
                          id: artworkId,
                          size: 300,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Scrim: keeps the artwork colour visible at the top and settles
          // into the theme background toward the controls.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  base.withValues(alpha: 0.35),
                  base.withValues(alpha: 0.70),
                  base.withValues(alpha: 0.97),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Soft glow behind the rotating artwork.
          Align(
            alignment: const Alignment(0, -0.45),
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.coral.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
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
            icon: Icon(LucideIcons.chevron_down, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
