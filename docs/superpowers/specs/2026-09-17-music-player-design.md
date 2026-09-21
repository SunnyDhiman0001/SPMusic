# Music Player App — Design Spec

Date: 2026-09-17

## Goal
Production-quality Flutter music player, dark-premium UI, Clean Architecture, BLoC/Cubit + flutter_hooks + ValueNotifier, mock data first, swappable to real backend later.

## Architecture
Feature-first Clean Architecture.

```
lib/
├── core/
│   ├── constants/  error/  extensions/  helpers/  network/
│   ├── router/      # go_router, centralized routes + transitions
│   ├── theme/        # AppColors, AppTextStyles, AppSpacing, AppRadius, AppTheme
│   ├── di/            # get_it setup
│   └── widgets/     # SongTile, AlbumCard, ArtistCard, PlaylistCard, MiniPlayer,
│                      AnimatedPlayButton, MusicProgressBar, CustomBottomNavBar,
│                      SectionHeader, ArtworkImage, FavoriteButton, QueueSheet,
│                      LoadingWidget, ErrorWidget, EmptyStateWidget
│
└── features/{splash,home,search,player,playlist,library}/
        data/{models,repositories,datasources}
        domain/{entities,repositories,usecases}
        presentation/{pages,widgets,bloc}
```

Hard rule: no file over ~300 lines. No business logic in widgets.

## State management split
- **Cubit** (flutter_bloc): PlayerCubit, HomeCubit, SearchCubit, LibraryCubit,
  PlaylistCubit, FavoritesCubit, QueueCubit — anything crossing widget boundaries
  or touching repositories.
- **flutter_hooks**: AnimationController, TextEditingController, ScrollController,
  PageController, lifecycle-bound local state.
- **ValueNotifier**: selected bottom-nav tab, favorite-heart micro animation,
  expand/collapse sections, volume slider UI, other purely local/ephemeral UI state.

## Dependency injection
get_it (`core/di/injector.dart`). Lazy singletons for services/repositories,
factories for Cubits. Presentation never instantiates a repository or
datasource directly.

## Routing
go_router, defined in `core/router/app_router.dart`.
Routes: `/splash /home /search /library /player /playlist/:id`.
Custom page transitions (fade/slide) per route.

## Data layer
- Entities: SongEntity, ArtistEntity, AlbumEntity, PlaylistEntity (domain, immutable, Equatable).
- Mock datasource: `LocalMusicDataSource` returns realistic sample data.
- `audioUrl` fields point to public SoundHelix demo MP3s so playback works for
  real via just_audio without needing a backend.
- Repository interfaces live in domain; implementations in data depend only on
  the datasource interface — swappable for a real API later with zero
  presentation-layer changes.

## Audio playback
- `AudioPlayerService` (data layer) wraps `just_audio` + `audio_session`.
  Exposes position/duration/playerState streams. This is the ONLY place the
  just_audio package is imported.
- `PlayerRepository` (domain interface, data impl) sits between the service and
  `PlayerCubit`. Handles play/pause/resume/stop/seek/next/previous/queue/
  shuffle/repeat, and surfaces loading/buffering/error/completion states.
- Widgets only ever talk to `PlayerCubit`.

## Theming
Dark theme is primary; light theme also implemented. Material 3.
Centralized `AppColors`/`AppTextStyles`/`AppSpacing`/`AppRadius` — no inline
hardcoded colors/radii in feature widgets.

## Animation
Hero for artwork (mini-player → full player), flutter_animate for entrance/
press animations, custom rotation for album art, AnimatedSwitcher for
play/pause icon morph, implicit animations for progress bar and bottom nav
indicator.

## Verification
Target platform for build/run checks: Android emulator.
Each phase: `flutter analyze` must be clean, app must build & run on Android,
file line-count cap respected, no dead code / no direct package use outside
its designated layer.

## Package additions
flutter_bloc, equatable, get_it, go_router, flutter_hooks, just_audio,
audio_session, cached_network_image, flutter_animate, shared_preferences.

## Delivery plan (phases, one at a time, verified before moving on)
1. Project scaffold: folder structure, theme, router, DI wiring, pubspec deps.
2. Splash + Home shell + bottom navigation (static UI, no real data yet).
3. Mock music data + repositories (Song/Artist/Album/Playlist).
4. PlayerCubit + AudioPlayerService (real just_audio playback against mock data).
5. MiniPlayer + full-screen Player UI, Hero transition.
6. Search feature (debounced, loading/empty/error states).
7. Library + Playlist detail screens.
8. Animation pass / visual polish.
9. Rebuild/performance optimization (BlocSelector, const, listenable scoping).
10. Final `flutter analyze` cleanup pass.

No git repository in this project (user declined git init) — phases are
delivered as plain file changes, not commits.
