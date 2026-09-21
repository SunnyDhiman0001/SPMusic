# Music Player Phase 2 — Splash + Home + Bottom Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Phase 1 placeholder Splash/Home pages with an animated splash screen, a real bottom-navigation shell (Home/Search/Library), and a static (hardcoded sample data) but visually complete Home screen with slivers, sections, and pull-to-refresh.

**Architecture:** Presentation-layer only. No domain/data layers yet (mock repositories arrive in Phase 3) — Home screen content uses a temporary local sample-data file that will be deleted and replaced by `HomeCubit` + repository data in Phase 3. Reusable visual pieces (`SectionHeader`, `ArtworkCard`, `CustomBottomNavBar`) go in `core/widgets` since every feature will reuse them later. Tab switching uses `ValueNotifier<int>` per the design spec (not a BLoC — it's pure local UI state).

**Tech Stack:** flutter_hooks (splash animation), ValueNotifier (tab selection), go_router (routing), cached_network_image (artwork), Material 3 theme from Phase 1.

---

## File Structure

```
lib/
├── core/
│   └── widgets/
│       ├── section_header.dart
│       ├── artwork_card.dart
│       └── custom_bottom_nav_bar.dart
├── core/router/app_router.dart          (modify: /home -> MainShellPage)
└── features/
    ├── splash/presentation/pages/splash_page.dart   (rewrite)
    └── home/presentation/
        ├── pages/
        │   ├── main_shell_page.dart      (new)
        │   └── home_page.dart            (rewrite)
        ├── home_sample_data.dart          (new, temporary)
        └── widgets/
            └── horizontal_card_list.dart  (new)
test/
├── core/widgets/artwork_card_test.dart
├── core/widgets/custom_bottom_nav_bar_test.dart
└── core/router/app_router_test.dart      (modify)
```

---

### Task 1: Reusable core widgets — SectionHeader and ArtworkCard

**Files:**
- Create: `lib/core/widgets/section_header.dart`
- Create: `lib/core/widgets/artwork_card.dart`
- Test: `test/core/widgets/artwork_card_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/artwork_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/artwork_card.dart';

void main() {
  testWidgets('ArtworkCard shows title, subtitle, and reacts to tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArtworkCard(
            imageUrl: 'https://example.com/art.jpg',
            title: 'Midnight City',
            subtitle: 'M83',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Midnight City'), findsOneWidget);
    expect(find.text('M83'), findsOneWidget);

    await tester.tap(find.byType(ArtworkCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/artwork_card_test.dart`
Expected: FAIL — `ArtworkCard` doesn't exist.

- [ ] **Step 3: Create SectionHeader**

```dart
// lib/core/widgets/section_header.dart
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create ArtworkCard**

```dart
// lib/core/widgets/artwork_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ArtworkCard extends StatefulWidget {
  const ArtworkCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.width = 150,
    this.isCircle = false,
    super.key,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double width;
  final bool isCircle;

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  double _scale = 1;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.isCircle ? AppRadius.roundRadius : AppRadius.mdRadius;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: radius,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: widget.width,
                  height: widget.width,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: widget.width,
                    height: widget.width,
                    color: theme.cardColor,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: widget.width,
                    height: widget.width,
                    color: theme.cardColor,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/widgets/artwork_card_test.dart`
Expected: PASS

- [ ] **Step 6: Save (no git — skip commit)**

---

### Task 2: CustomBottomNavBar

**Files:**
- Create: `lib/core/widgets/custom_bottom_nav_bar.dart`
- Test: `test/core/widgets/custom_bottom_nav_bar_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/custom_bottom_nav_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/custom_bottom_nav_bar.dart';

void main() {
  const items = [
    NavTabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    NavTabItem(icon: Icons.search, activeIcon: Icons.search, label: 'Search'),
    NavTabItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music, label: 'Library'),
  ];

  testWidgets('CustomBottomNavBar reports tapped index', (tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 0,
            items: items,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(tappedIndex, 1);
  });

  testWidgets('CustomBottomNavBar does not fire onTap for already-selected tab', (tester) async {
    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 0,
            items: items,
            onTap: (_) => callCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(callCount, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/custom_bottom_nav_bar_test.dart`
Expected: FAIL — `CustomBottomNavBar`/`NavTabItem` don't exist.

- [ ] **Step 3: Create CustomBottomNavBar**

```dart
// lib/core/widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class NavTabItem {
  const NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final List<NavTabItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++) _buildTab(context, i),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final theme = Theme.of(context);
    final selected = index == selectedIndex;
    final item = items[index];
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTap: () {
        if (!selected) {
          HapticFeedback.selectionClick();
          onTap(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: AppRadius.roundRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelSmall!.copyWith(color: color),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/custom_bottom_nav_bar_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Save (no git — skip commit)**

---

### Task 3: MainShellPage + router wiring

**Files:**
- Create: `lib/features/home/presentation/pages/main_shell_page.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `test/core/router/app_router_test.dart`

Context: `HomePage`, `SearchPage`, `LibraryPage` already exist as placeholder Scaffolds from Phase 1 (they get real content in Task 5 of this plan and in Phase 6/7 respectively). `CustomBottomNavBar`/`NavTabItem` from Task 2 exist.

- [ ] **Step 1: Create MainShellPage**

```dart
// lib/features/home/presentation/pages/main_shell_page.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../library/presentation/pages/library_page.dart';
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
          body: IndexedStack(index: index, children: _pages),
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
```

- [ ] **Step 2: Update AppRouter — point `/home` to MainShellPage**

In `lib/core/router/app_router.dart`, add the import and change the `/home` route builder:

```dart
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_shell_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/player/presentation/pages/player_page.dart';
import '../../features/playlist/presentation/pages/playlist_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/home', builder: (context, state) => const MainShellPage()),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(path: '/library', builder: (context, state) => const LibraryPage()),
      GoRoute(path: '/player', builder: (context, state) => const PlayerPage()),
      GoRoute(
        path: '/playlist/:id',
        builder: (context, state) => PlaylistPage(
          playlistId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
```

(The `home_page.dart` import stays because `HomePage` is still directly referenced by `MainShellPage`, not by the router — keep it if the analyzer requires it, remove it if unused after this edit. Verify with `flutter analyze` in Task 6.)

- [ ] **Step 3: Update the router test**

The old test expected `find.text('Home')` right after `pumpAndSettle()` at `/splash`, and assumed `/home` rendered a bare `HomePage` with literal text `'Home'`. Both assumptions are now false: `SplashPage` is animated (Task 4 of this plan) and `/home` renders `MainShellPage`, not literal text. Replace the whole test file:

```dart
// test/core/router/app_router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/router/app_router.dart';
import 'package:spmusic/features/home/presentation/pages/main_shell_page.dart';

void main() {
  testWidgets('router starts at /splash and navigates to /home shell', (tester) async {
    final router = AppRouter.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // Single pump only: SplashPage plays a short entrance animation and
    // auto-navigates after a delay. pumpAndSettle would fast-forward through
    // both, so we deliberately render just the first frame to assert on the
    // splash content before it transitions away.
    await tester.pump();
    expect(find.text('SPMusic'), findsOneWidget);

    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.byType(MainShellPage), findsOneWidget);
  });
}
```

- [ ] **Step 4: Confirm this test currently fails for the right reason**

Run: `flutter test test/core/router/app_router_test.dart`
Expected: FAIL — `SplashPage` still shows old placeholder text `'Splash'`, not `'SPMusic'` (Task 4 not done yet). This is expected; do not fix it in this task.

- [ ] **Step 5: Save (no git — skip commit)**

---

### Task 4: Animated SplashPage

**Files:**
- Modify: `lib/features/splash/presentation/pages/splash_page.dart`

Context: `flutter_hooks` and `go_router` are already dependencies. `AppColors` (with `darkBackgroundGradient`, `primary`, `white`, `textPrimaryDark`) exists from Phase 1.

- [ ] **Step 1: Rewrite SplashPage as an animated HookWidget**

```dart
// lib/features/splash/presentation/pages/splash_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends HookWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    final scale = useMemoized(
      () => Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      ),
      [controller],
    );

    final opacity = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeIn),
      [controller],
    );

    useEffect(() {
      controller.forward();
      final navigationTimer = Timer(const Duration(milliseconds: 2200), () {
        if (context.mounted) context.go('/home');
      });
      return navigationTimer.cancel;
    }, const []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.darkBackgroundGradient,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: opacity,
            child: ScaleTransition(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      color: AppColors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SPMusic',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the router test from Task 3**

Run: `flutter test test/core/router/app_router_test.dart`
Expected: PASS

- [ ] **Step 3: Save (no git — skip commit)**

---

### Task 5: Home sample data, HorizontalCardList, and real HomePage content

**Files:**
- Create: `lib/features/home/presentation/home_sample_data.dart`
- Create: `lib/features/home/presentation/widgets/horizontal_card_list.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`

Context: this is presentation-only sample content. It will be deleted in Phase 3 when `HomeCubit` + a real repository provide this data instead — do not treat `HomeSampleData` as a permanent domain concept.

- [ ] **Step 1: Create HomeSampleData**

```dart
// lib/features/home/presentation/home_sample_data.dart
class HomeCardData {
  const HomeCardData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
}

class HomeSampleData {
  const HomeSampleData._();

  static const List<HomeCardData> recentlyPlayed = [
    HomeCardData(
      id: 'rp1',
      imageUrl: 'https://picsum.photos/seed/rp1/300',
      title: 'Midnight Drive',
      subtitle: 'Nova Wave',
    ),
    HomeCardData(
      id: 'rp2',
      imageUrl: 'https://picsum.photos/seed/rp2/300',
      title: 'Golden Hour',
      subtitle: 'Aria Storm',
    ),
    HomeCardData(
      id: 'rp3',
      imageUrl: 'https://picsum.photos/seed/rp3/300',
      title: 'City Lights',
      subtitle: 'The Drift',
    ),
  ];

  static const List<HomeCardData> madeForYou = [
    HomeCardData(
      id: 'mfy1',
      imageUrl: 'https://picsum.photos/seed/mfy1/300',
      title: 'Focus Flow',
      subtitle: 'Curated for you',
    ),
    HomeCardData(
      id: 'mfy2',
      imageUrl: 'https://picsum.photos/seed/mfy2/300',
      title: 'Late Night Chill',
      subtitle: 'Curated for you',
    ),
  ];

  static const List<HomeCardData> trending = [
    HomeCardData(
      id: 't1',
      imageUrl: 'https://picsum.photos/seed/t1/300',
      title: 'Electric Skyline',
      subtitle: 'Nova Wave',
    ),
    HomeCardData(
      id: 't2',
      imageUrl: 'https://picsum.photos/seed/t2/300',
      title: 'Paper Planes',
      subtitle: 'Aria Storm',
    ),
    HomeCardData(
      id: 't3',
      imageUrl: 'https://picsum.photos/seed/t3/300',
      title: 'Afterglow',
      subtitle: 'The Drift',
    ),
  ];

  static const List<HomeCardData> popularArtists = [
    HomeCardData(
      id: 'a1',
      imageUrl: 'https://picsum.photos/seed/a1/300',
      title: 'Nova Wave',
      subtitle: 'Artist',
    ),
    HomeCardData(
      id: 'a2',
      imageUrl: 'https://picsum.photos/seed/a2/300',
      title: 'Aria Storm',
      subtitle: 'Artist',
    ),
    HomeCardData(
      id: 'a3',
      imageUrl: 'https://picsum.photos/seed/a3/300',
      title: 'The Drift',
      subtitle: 'Artist',
    ),
  ];
}
```

- [ ] **Step 2: Create HorizontalCardList**

```dart
// lib/features/home/presentation/widgets/horizontal_card_list.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/artwork_card.dart';
import '../home_sample_data.dart';

class HorizontalCardList extends StatelessWidget {
  const HorizontalCardList({
    required this.items,
    this.isCircle = false,
    this.cardWidth = 150,
    super.key,
  });

  final List<HomeCardData> items;
  final bool isCircle;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth + 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return ArtworkCard(
            imageUrl: item.imageUrl,
            title: item.title,
            subtitle: item.subtitle,
            width: cardWidth,
            isCircle: isCircle,
            onTap: () {},
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Rewrite HomePage**

```dart
// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';
import '../home_sample_data.dart';
import '../widgets/horizontal_card_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _onRefresh() => Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
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
          const SliverToBoxAdapter(child: SectionHeader(title: 'Recently Played')),
          SliverToBoxAdapter(
            child: HorizontalCardList(items: HomeSampleData.recentlyPlayed),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Made For You')),
          SliverToBoxAdapter(
            child: HorizontalCardList(items: HomeSampleData.madeForYou, cardWidth: 180),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Trending Now')),
          SliverToBoxAdapter(
            child: HorizontalCardList(items: HomeSampleData.trending),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Popular Artists')),
          SliverToBoxAdapter(
            child: HorizontalCardList(
              items: HomeSampleData.popularArtists,
              isCircle: true,
              cardWidth: 100,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run full test suite**

Run: `flutter test`
Expected: all tests PASS (theme: 2, router: 1, artwork_card: 1, bottom_nav: 2 = 6 tests).

- [ ] **Step 5: Save (no git — skip commit)**

---

### Task 6: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Static analysis**

Run: `flutter analyze`
Expected: `No issues found!`. If `home_page.dart` import in `app_router.dart` (Task 3, Step 2) is flagged unused, remove it.

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 3: Build and run on Android**

Run: `flutter run -d emulator-5554` (or whichever Android device/emulator is connected — check with `flutter devices` first)
Expected: App launches, shows the animated splash (gradient background, glowing circular logo, "SPMusic" text), auto-transitions to the Home tab after ~2.2s showing greeting header, avatar, and four horizontally-scrolling sections with network images (SoundHelix/picsum artwork loading — allow a few seconds), plus a bottom nav bar with Home/Search/Library. Tapping Search/Library switches tabs with haptic feedback and highlight animation, no crashes.

- [ ] **Step 4: Save (no git — skip commit)**

---

## Self-Review Notes

- **Spec coverage:** Covers design-doc Phase 2 exactly — Splash (animated, gradient, glow, logo, app name, auto-transition), Home (greeting, avatar, recently played, made for you, trending, popular artists, slivers, pull-to-refresh, card tap-scale animation), Bottom Navigation (animated indicator/icon, haptic feedback, ValueNotifier-driven, safe area). Search/Library screens remain Phase-1 placeholders — real content is Phase 6/7 per the design doc's phase list, intentionally out of scope here.
- **Placeholder scan:** none — every step has complete runnable code.
- **Type consistency:** `HomeCardData` fields (`id`, `imageUrl`, `title`, `subtitle`) used identically in `HomeSampleData` and `HorizontalCardList`. `NavTabItem` fields (`icon`, `activeIcon`, `label`) match between `custom_bottom_nav_bar.dart` and `main_shell_page.dart`. `ArtworkCard` constructor params (`imageUrl`, `title`, `subtitle`, `onTap`, `width`, `isCircle`) match every call site.
- **Known risk flagged inline:** Task 3/4 call out exactly why the router test must change (SplashPage is no longer static text, `/home` no longer renders bare `HomePage`) and why the test uses a single `pump()` instead of `pumpAndSettle()` for the splash assertion (avoids the fake-async clock fast-forwarding through the splash's animation and auto-navigation before the assertion runs).
