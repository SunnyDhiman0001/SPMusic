import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../library/presentation/pages/library_page.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../../search/presentation/pages/search_page.dart';
import 'home_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  final ValueNotifier<int> _selectedTab = ValueNotifier<int>(0);

  static const List<Widget> _pages = [HomePage(), SearchPage(), LibraryPage()];

  static const List<NavTabItem> _items = [
    NavTabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    NavTabItem(icon: Icons.search, activeIcon: Icons.search, label: 'Search'),
    NavTabItem(
      icon: Icons.library_music_outlined,
      activeIcon: Icons.library_music,
      label: 'Library',
    ),
  ];

  @override
  void dispose() {
    _selectedTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedTab,
      builder: (context, index, _) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(child: IndexedStack(index: index, children: _pages)),
              const MiniPlayer(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: CustomBottomNavBar(
              selectedIndex: index,
              items: _items,
              onTap: (i) => _selectedTab.value = i,
            ),
          ),
        );
      },
    );
  }
}
