import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/folders_cubit.dart';

/// The audio files inside one folder.
class FolderPage extends StatelessWidget {
  const FolderPage({required this.folderPath, required this.folderName, super.key});

  final String folderPath;
  final String folderName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FolderSongsCubit>()..load(folderPath),
      child: Scaffold(
        appBar: AppBar(title: Text(folderName, style: Theme.of(context).textTheme.headlineMedium)),
        body: SafeArea(
          child: BlocBuilder<FolderSongsCubit, FolderSongsState>(
            builder: (context, state) {
              final cubit = context.read<FolderSongsCubit>();
              return switch (state) {
                FolderSongsLoading() => const Center(child: CircularProgressIndicator()),
                FolderSongsError(:final message) =>
                  Center(child: Text('Something went wrong: $message')),
                FolderSongsLoaded(:final songs) when songs.isEmpty => RefreshIndicator(
                    onRefresh: () => cubit.load(folderPath, rescan: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              Icon(LucideIcons.folder_open, size: 64),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'No playable audio in this folder.\nPull to refresh if you just added files.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                FolderSongsLoaded(:final songs) => RefreshIndicator(
                    onRefresh: () => cubit.load(folderPath, rescan: true),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SearchSongTile(
                          song: song,
                          leadingBorderRadius: AppRadius.roundRadius,
                          onTap: () => context.read<PlayerCubit>().playQueue(songs, startIndex: index),
                          trailing: BlocSelector<FavoritesCubit, FavoritesState, bool>(
                            selector: (s) => s is FavoritesLoaded && s.isFavorite(song.id),
                            builder: (context, isFavorite) => FavoriteButton(
                              isFavorite: isFavorite,
                              size: 24,
                              onTap: () => context.read<FavoritesCubit>().toggleFavorite(song.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}
