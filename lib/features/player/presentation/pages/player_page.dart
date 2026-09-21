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
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? AppColors.darkBackgroundGradient
                          : AppColors.lightBackgroundGradient,
                    ),
                  ),
                ),
              ),
              if (song != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: _BlurredArtworkBackdrop(artworkId: song.artworkId),
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

/// Large blurred album cover that fades out into the Ink Black/Prussian Blue
/// background gradient, per the Now Playing design brief.
class _BlurredArtworkBackdrop extends StatelessWidget {
  const _BlurredArtworkBackdrop({required this.artworkId});

  final int artworkId;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
          stops: [0.35, 1.0],
        ).createShader(rect),
        blendMode: BlendMode.dstIn,
        child: ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: LocalArtwork(kind: ArtworkKind.song, id: artworkId, size: 400),
            ),
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
            icon: Icon(LucideIcons.chevron_down, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
