# Music Player Phase 1 — Project Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up Clean Architecture scaffold — folder structure, centralized theme, go_router, get_it DI — with placeholder pages for all six features, wired into `main.dart`, building and running clean on Android.

**Architecture:** Feature-first Clean Architecture per `docs/superpowers/specs/2026-09-17-music-player-design.md`. This phase only creates the skeleton (theme/router/DI/placeholder pages) — no business logic, no mock data, no audio yet (later phases).

**Tech Stack:** Flutter/Dart, flutter_bloc, equatable, get_it, go_router, flutter_hooks, just_audio, audio_session, cached_network_image, flutter_animate, shared_preferences.

**Note:** No git repository in this project (user declined `git init`). Every "Commit" step below is replaced with "Save (no git — skip commit)".

---

## File Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   └── app_theme.dart
│   ├── di/
│   │   └── injector.dart
│   └── router/
│       └── app_router.dart
├── features/
│   ├── splash/presentation/pages/splash_page.dart
│   ├── home/presentation/pages/home_page.dart
│   ├── search/presentation/pages/search_page.dart
│   ├── library/presentation/pages/library_page.dart
│   ├── player/presentation/pages/player_page.dart
│   └── playlist/presentation/pages/playlist_page.dart
└── main.dart
test/
├── core/theme/app_theme_test.dart
└── core/router/app_router_test.dart
```

---

### Task 1: Add dependencies to pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependencies**

Replace the `dependencies:` block in `pubspec.yaml` with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc: ^9.1.0
  equatable: ^2.0.5
  get_it: ^8.0.3
  go_router: ^14.6.2
  flutter_hooks: ^0.20.5
  just_audio: ^0.9.42
  audio_session: ^0.1.24
  cached_network_image: ^3.4.1
  flutter_animate: ^4.5.2
  shared_preferences: ^2.3.4
```

- [ ] **Step 2: Fetch packages**

Run: `flutter pub get`
Expected: `Got dependencies!` with no version conflicts. If a version is yanked/incompatible, run `flutter pub outdated` and adjust the pinned version, then re-run.

- [ ] **Step 3: Save (no git — skip commit)**

---

### Task 2: Core theme files

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_spacing.dart`
- Create: `lib/core/theme/app_radius.dart`
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `lib/core/theme/app_theme.dart`
- Test: `test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('dark theme uses dark brightness and Material 3', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
    });

    test('light theme uses light brightness and Material 3', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'spmusic'` or `Target of URI doesn't exist: 'package:spmusic/core/theme/app_theme.dart'` (file doesn't exist yet).

- [ ] **Step 3: Create AppColors**

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color black = Color(0xFF0A0A0C);
  static const Color charcoal = Color(0xFF16161A);
  static const Color surfaceDark = Color(0xFF1E1E24);
  static const Color cardDark = Color(0xFF232329);

  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryVariant = Color(0xFF5E35F2);
  static const Color accent = Color(0xFF00E5C7);

  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFFA0A0AB);

  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF14141A);
  static const Color textSecondaryLight = Color(0xFF6E6E78);

  static const Color error = Color(0xFFFF5470);

  static const List<Color> darkBackgroundGradient = [black, charcoal];
}
```

- [ ] **Step 4: Create AppSpacing**

```dart
// lib/core/theme/app_spacing.dart
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
```

- [ ] **Step 5: Create AppRadius**

```dart
// lib/core/theme/app_radius.dart
import 'package:flutter/widgets.dart';

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double round = 999;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get roundRadius => BorderRadius.circular(round);
}
```

- [ ] **Step 6: Create AppTextStyles**

```dart
// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Roboto';

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );
}
```

- [ ] **Step 7: Create AppTheme**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSurface: AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.black,
      cardColor: AppColors.cardDark,
      textTheme: _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSurface: AppColors.textPrimaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      cardColor: AppColors.cardLight,
      textTheme: _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static TextTheme _textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: primaryColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: primaryColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: primaryColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: primaryColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: secondaryColor),
    );
  }
}
```

- [ ] **Step 8: Run test to verify it passes**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 9: Save (no git — skip commit)**

---

### Task 3: Placeholder pages for all six features

**Files:**
- Create: `lib/features/splash/presentation/pages/splash_page.dart`
- Create: `lib/features/home/presentation/pages/home_page.dart`
- Create: `lib/features/search/presentation/pages/search_page.dart`
- Create: `lib/features/library/presentation/pages/library_page.dart`
- Create: `lib/features/player/presentation/pages/player_page.dart`
- Create: `lib/features/playlist/presentation/pages/playlist_page.dart`

- [ ] **Step 1: Create SplashPage**

```dart
// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Splash')),
    );
  }
}
```

- [ ] **Step 2: Create HomePage**

```dart
// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home')),
    );
  }
}
```

- [ ] **Step 3: Create SearchPage**

```dart
// lib/features/search/presentation/pages/search_page.dart
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Search')),
    );
  }
}
```

- [ ] **Step 4: Create LibraryPage**

```dart
// lib/features/library/presentation/pages/library_page.dart
import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Library')),
    );
  }
}
```

- [ ] **Step 5: Create PlayerPage**

```dart
// lib/features/player/presentation/pages/player_page.dart
import 'package:flutter/material.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Player')),
    );
  }
}
```

- [ ] **Step 6: Create PlaylistPage**

```dart
// lib/features/playlist/presentation/pages/playlist_page.dart
import 'package:flutter/material.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({required this.playlistId, super.key});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Playlist $playlistId')),
    );
  }
}
```

- [ ] **Step 7: Save (no git — skip commit)**

---

### Task 4: App router

**Files:**
- Create: `lib/core/router/app_router.dart`
- Test: `test/core/router/app_router_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/router/app_router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/router/app_router.dart';

void main() {
  testWidgets('router starts at /splash and navigates to /home', (tester) async {
    final router = AppRouter.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Splash'), findsOneWidget);

    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/router/app_router_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:spmusic/core/router/app_router.dart'`

- [ ] **Step 3: Create AppRouter**

```dart
// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
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
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/router/app_router_test.dart`
Expected: PASS (1 test)

- [ ] **Step 5: Save (no git — skip commit)**

---

### Task 5: DI injector

**Files:**
- Create: `lib/core/di/injector.dart`

- [ ] **Step 1: Create injector**

```dart
// lib/core/di/injector.dart
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjector() async {
  // Feature registrations (repositories, services, cubits) are added
  // phase-by-phase as each feature's data/domain layer is built.
}
```

- [ ] **Step 2: Save (no git — skip commit)**

---

### Task 6: Wire main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace main.dart contents**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const SpMusicApp());
}

class SpMusicApp extends StatelessWidget {
  const SpMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'spmusic',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.router,
    );
  }
}
```

- [ ] **Step 2: Remove the default counter widget test**

The default Flutter template ships `test/widget_test.dart` which references
`MyApp`/counter UI that no longer exists. Delete it.

Run: `rm test/widget_test.dart` (bash) or `Remove-Item test/widget_test.dart` (PowerShell)

- [ ] **Step 3: Save (no git — skip commit)**

---

### Task 7: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Static analysis**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: All tests pass (3 tests: 2 theme + 1 router).

- [ ] **Step 3: Build and run on Android**

Run: `flutter run -d android` (with an emulator/device attached)
Expected: App launches showing the Splash placeholder screen with dark
background, no red error screens, no exceptions in console.

- [ ] **Step 4: Save (no git — skip commit)**

---

## Self-Review Notes

- **Spec coverage:** This phase covers spec section "PHASE 1: architecture,
  theme, routing, DI" only. Home/Search/Library/Player/Playlist real content,
  mock data, bottom nav, mini-player, and audio come in later phases per the
  design doc's phase list — intentionally out of scope here.
- **Placeholder scan:** none found — every step has full runnable code.
- **Type consistency:** `AppRouter.router` (static getter-like field) used
  identically in main.dart and the router test. `PlaylistPage(playlistId:)`
  constructor matches the router's `state.pathParameters['id']!` usage.
