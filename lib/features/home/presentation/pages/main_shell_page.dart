import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import 'home_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;

  static const _pages = [HomePage(), FavoritesPage()];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Icon/label color never changes with selection — only the pill behind
    // the selected icon does. Dark mode keeps white text/icons throughout;
    // light mode keeps whatever color the unselected tabs already used.
    final tabColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    final selectedIndicatorColor = theme.colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          // The selected icon sits inside a solid primary-colored pill, so
          // it needs a light/white color to stay legible. The label sits
          // below the pill on the plain nav bar background, so it always
          // uses the same tabColor regardless of selection.
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? theme.colorScheme.onPrimary
                  : tabColor,
            ),
          ),
          labelTextStyle: WidgetStatePropertyAll(
            theme.textTheme.labelSmall?.copyWith(color: tabColor),
          ),
        ),
        child: NavigationBar(
          backgroundColor: theme.cardColor,
          indicatorColor: selectedIndicatorColor,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.house), label: 'Home'),
            NavigationDestination(
              icon: Icon(LucideIcons.heart),
              label: 'Favourites',
            ),
          ],
        ),
      ),
    );
  }
}
