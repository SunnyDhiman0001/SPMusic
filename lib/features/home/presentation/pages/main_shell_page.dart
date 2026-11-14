import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_nav_bar.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../folders/presentation/pages/folders_page.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import 'home_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> with SingleTickerProviderStateMixin {
  /// Space the floating mini-player occupies at the bottom of the pages
  /// (card height plus its vertical margins).
  static const double _miniPlayerInset = 84;

  static const _pages = [HomePage(), FoldersPage(), FavoritesPage()];

  static const _navItems = [
    AppNavItem(icon: LucideIcons.house, label: 'Home'),
    AppNavItem(icon: LucideIcons.folder, label: 'Folders'),
    AppNavItem(icon: LucideIcons.heart, label: 'Favourites'),
  ];

  int _selectedIndex = 0;

  // Brief fade when switching tabs. The pages stay mounted in the IndexedStack
  // (so their state survives); only the fade is replayed.
  late final AnimationController _tabFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _tabFade.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final hasSong = context.select((PlayerCubit cubit) => cubit.state.currentSong != null);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      // The mini-player floats over the pages so its backdrop blur shows the
      // list scrolling behind it. Pages keep their content clear of it by
      // honouring the bottom padding (they all use SafeArea(bottom: true)).
      body: AppBackground(
        child: Stack(
          children: [
            MediaQuery(
              data: mediaQuery.copyWith(
                padding: mediaQuery.padding.copyWith(
                  bottom: mediaQuery.padding.bottom + (hasSong ? _miniPlayerInset : 0),
                ),
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _tabFade, curve: Curves.easeOut),
                child: IndexedStack(index: _selectedIndex, children: _pages),
              ),
            ),
            const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
          ],
        ),
      ),
      bottomNavigationBar: AppNavBar(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onSelected: _selectTab,
      ),
    );
  }
}
