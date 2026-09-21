import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/main_shell_page.dart';
import '../../features/player/presentation/pages/player_page.dart';
import '../../features/playlist/presentation/pages/playlist_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

CustomTransitionPage<void> _fadeSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/home', builder: (context, state) => const MainShellPage()),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(
        path: '/player',
        pageBuilder: (context, state) => _fadeSlidePage(const PlayerPage(), state),
      ),
      GoRoute(
        path: '/playlist/:id',
        pageBuilder: (context, state) => _fadeSlidePage(
          PlaylistPage(playlistId: state.pathParameters['id']!),
          state,
        ),
      ),
    ],
  );
}
