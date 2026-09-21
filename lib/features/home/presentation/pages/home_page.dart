import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/horizontal_card_list.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../music/domain/repositories/music_repository.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
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
          floatingActionButton: state is HomeLoaded
              ? FloatingActionButton(
                  onPressed: () async {
                    final songs = await sl<MusicRepository>().getAllSongs();
                    if (context.mounted) {
                      context.read<PlayerCubit>().playQueue(songs);
                    }
                  },
                  child: const Icon(Icons.play_arrow),
                )
              : null,
          body: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().refresh(),
          child: switch (state) {
            HomeInitial() || HomeLoading() => const Center(child: CircularProgressIndicator()),
            HomeError(:final message) => Center(child: Text('Something went wrong: $message')),
            HomeLoaded() => CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Text(_greeting, style: theme.textTheme.headlineMedium),
                    actions: const [
                      Padding(
                        padding: EdgeInsets.only(right: AppSpacing.md),
                        child: CircleAvatar(child: Icon(Icons.person)),
                      ),
                    ],
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: 'Recently Played'),
                        HorizontalCardList(items: state.recentlyPlayed),
                      ],
                    ).animate().fadeIn(delay: 0.ms, duration: 300.ms).slideY(
                          begin: 0.08,
                          end: 0,
                          delay: 0.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: 'Made For You'),
                        HorizontalCardList(items: state.madeForYou, cardWidth: 180),
                      ],
                    ).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(
                          begin: 0.08,
                          end: 0,
                          delay: 80.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: 'Trending Now'),
                        HorizontalCardList(items: state.trending),
                      ],
                    ).animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(
                          begin: 0.08,
                          end: 0,
                          delay: 160.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: 'Popular Artists'),
                        HorizontalCardList(
                          items: state.popularArtists,
                          isCircle: true,
                          cardWidth: 100,
                        ),
                      ],
                    ).animate().fadeIn(delay: 240.ms, duration: 300.ms).slideY(
                          begin: 0.08,
                          end: 0,
                          delay: 240.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                ],
              ),
          },
          ),
        );
      },
    );
  }
}
