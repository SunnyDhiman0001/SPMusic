import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_mode_cubit.dart';
import '../../../../core/widgets/no_music_found_view.dart';
import '../../../../core/widgets/permission_denied_view.dart';
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: state is HomeLoaded && state.songs.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => context.read<PlayerCubit>().playQueue(state.songs),
                  child: const Icon(LucideIcons.play),
                )
              : null,
          body: switch (state) {
            HomeInitial() || HomeLoading() => const Center(child: CircularProgressIndicator()),
            HomeError(:final message) => Center(child: Text('Something went wrong: $message')),
            HomePermissionDenied(:final permanentlyDenied) => CustomScrollView(
                slivers: [
                  _HomeAppBar(greeting: _greeting, theme: theme),
                  SliverFillRemaining(
                    child: PermissionDeniedView(
                      permanentlyDenied: permanentlyDenied,
                      onRequestPermission: () => context.read<HomeCubit>().requestPermission(),
                      onOpenSettings: () => context.read<HomeCubit>().openPermissionSettings(),
                    ),
                  ),
                ],
              ),
            HomeLoaded(isEmpty: true) => CustomScrollView(
                slivers: [
                  _HomeAppBar(greeting: _greeting, theme: theme),
                  const SliverFillRemaining(child: NoMusicFoundView()),
                ],
              ),
            HomeLoaded(:final songs) => RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: CustomScrollView(
                  slivers: [
                    _HomeAppBar(greeting: _greeting, theme: theme),
                    SliverList.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) => SearchSongTile(
                        song: songs[index],
                        leadingBorderRadius: AppRadius.roundRadius,
                        onTap: () => context.read<PlayerCubit>().playQueue(songs, startIndex: index),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  ],
                ),
              ),
          },
        );
      },
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.greeting, required this.theme});

  final String greeting;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: Text(greeting, style: theme.textTheme.headlineMedium),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.search),
          tooltip: 'Search',
          onPressed: () => context.push('/search'),
        ),
        BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, mode) => IconButton(
            icon: Icon(mode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun),
            tooltip: mode == ThemeMode.dark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => context.read<ThemeModeCubit>().toggle(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
