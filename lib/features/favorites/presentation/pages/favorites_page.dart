import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/favorites_cubit.dart';
import '../bloc/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            return switch (state) {
              FavoritesLoading() => const Center(child: CircularProgressIndicator()),
              FavoritesError(:final message) =>
                Center(child: Text('Something went wrong: $message')),
              FavoritesLoaded(songs: final songs) when songs.isEmpty => RefreshIndicator(
                  onRefresh: () => context.read<FavoritesCubit>().refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(
                          child: Text(
                            'No favorite songs yet.\nTap the heart on a song to add it here.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              FavoritesLoaded(:final songs) => RefreshIndicator(
                  onRefresh: () => context.read<FavoritesCubit>().refresh(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SearchSongTile(
                        song: song,
                        leadingBorderRadius: AppRadius.roundRadius,
                        onTap: () =>
                            context.read<PlayerCubit>().playQueue(songs, startIndex: index),
                        trailing: FavoriteButton(
                          isFavorite: true,
                          size: 24,
                          onTap: () => context.read<FavoritesCubit>().toggleFavorite(song.id),
                        ),
                      );
                    },
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}
