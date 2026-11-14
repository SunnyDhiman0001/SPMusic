import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/entrance.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/no_music_found_view.dart';
import '../../../../core/widgets/permission_denied_view.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/widgets/now_playing_tile_builder.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../bloc/recently_played_cubit.dart';
import '../widgets/recently_played_section.dart';
import '../widgets/shuffle_all_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()..loadHome()),
        BlocProvider<RecentlyPlayedCubit>.value(value: sl<RecentlyPlayedCubit>()..load()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: state is HomeLoaded && state.songs.isNotEmpty
              ? ShuffleAllButton(songs: state.songs)
              : null,
          body: SafeArea(
            top: true,
            bottom: true,
            child: switch (state) {
              HomeInitial() ||
              HomeLoading() => const Center(child: CircularProgressIndicator()),
              HomeError(:final message) => Center(
                child: Text('Something went wrong: $message'),
              ),
              HomePermissionDenied(:final permanentlyDenied) =>
                CustomScrollView(
                  slivers: [
                    const _HomeAppBar(),
                    SliverFillRemaining(
                      child: PermissionDeniedView(
                        permanentlyDenied: permanentlyDenied,
                        onRequestPermission: () =>
                            context.read<HomeCubit>().requestPermission(),
                        onOpenSettings: () =>
                            context.read<HomeCubit>().openPermissionSettings(),
                      ),
                    ),
                  ],
                ),
              HomeLoaded(isEmpty: true) => const CustomScrollView(
                slivers: [
                  _HomeAppBar(),
                  SliverFillRemaining(child: NoMusicFoundView()),
                ],
              ),
              HomeLoaded(:final songs) => RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: CustomScrollView(
                  slivers: [
                    const _HomeAppBar(),
                    const SliverToBoxAdapter(child: RecentlyPlayedSection()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          'Tracks',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) => Entrance(
                        index: index,
                        child: NowPlayingTileBuilder(
                        songId: songs[index].id,
                        builder: (context, isCurrent, isPlaying) => SearchSongTile(
                          song: songs[index],
                          isCurrent: isCurrent,
                          isPlaying: isPlaying,
                          onTap: () => context.read<PlayerCubit>().playQueue(
                            songs,
                            startIndex: index,
                          ),
                          trailing: BlocSelector<FavoritesCubit, FavoritesState, bool>(
                            selector: (state) =>
                                state is FavoritesLoaded &&
                                state.isFavorite(songs[index].id),
                            builder: (context, isFavorite) => FavoriteButton(
                              isFavorite: isFavorite,
                              size: 24,
                              onTap: () => context.read<FavoritesCubit>().toggleFavorite(
                                songs[index].id,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                    // Tall enough to scroll the last row clear of the shuffle button.
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl * 2),
                    ),
                  ],
                ),
              ),
            },
          ),
        );
      },
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      titleSpacing: AppSpacing.md,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: AppRadius.smRadius,
            child: Image.asset('assets/icon/logo.png', width: 28, height: 28),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text.rich(
            TextSpan(
              style: theme.textTheme.headlineMedium,
              children: const [
                TextSpan(
                  text: 'SP',
                  style: TextStyle(color: AppColors.logoOrange),
                ),
                TextSpan(text: 'Music'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.search),
          tooltip: 'Search',
          onPressed: () => context.push('/search'),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
