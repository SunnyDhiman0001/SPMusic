import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_mode_cubit.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/no_music_found_view.dart';
import '../../../../core/widgets/permission_denied_view.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadHome(),
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
          floatingActionButton: state is HomeLoaded && state.songs.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () =>
                      context.read<PlayerCubit>().playQueue(state.songs),
                  child: const Icon(LucideIcons.play),
                )
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
                    SliverList.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) => SearchSongTile(
                        song: songs[index],
                        leadingBorderRadius: AppRadius.roundRadius,
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
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl),
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
        BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, mode) => IconButton(
            icon: Icon(
              mode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun,
            ),
            tooltip: mode == ThemeMode.dark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            onPressed: () => context.read<ThemeModeCubit>().toggle(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
