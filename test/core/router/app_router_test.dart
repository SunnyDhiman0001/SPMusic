import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmusic/core/di/injector.dart';
import 'package:spmusic/core/router/app_router.dart';
import 'package:spmusic/core/theme/app_theme.dart';
import 'package:spmusic/core/theme/theme_mode_cubit.dart';
import 'package:spmusic/features/home/presentation/pages/main_shell_page.dart';
import 'package:spmusic/features/music/data/datasources/local_music_data_source.dart';
import 'package:spmusic/features/music/data/models/album_model.dart';
import 'package:spmusic/features/music/data/models/artist_model.dart';
import 'package:spmusic/features/music/data/models/playlist_model.dart';
import 'package:spmusic/features/music/data/models/song_model.dart';
import 'package:spmusic/features/music/data/services/music_permission_service.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';

class _FakeLocalMusicDataSource implements LocalMusicDataSource {
  @override
  Future<List<SongModel>> getSongs() async => [];

  @override
  Future<List<ArtistModel>> getArtists() async => [];

  @override
  Future<List<AlbumModel>> getAlbums() async => [];

  @override
  Future<List<PlaylistModel>> getPlaylists() async => [];

  @override
  void invalidateCache() {}
}

class _FakeMusicPermissionService implements MusicPermissionService {
  @override
  Future<MusicPermissionStatus> check() async => MusicPermissionStatus.granted;

  @override
  Future<MusicPermissionStatus> request() async => MusicPermissionStatus.granted;

  @override
  Future<void> openSettings() async {}
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await setupInjector();

    // Swap the real MediaStore-backed services for fakes: the real ones talk
    // to platform channels that aren't mocked in this widget-test environment
    // and would otherwise hang pumpAndSettle forever.
    sl.unregister<LocalMusicDataSource>();
    sl.registerLazySingleton<LocalMusicDataSource>(() => _FakeLocalMusicDataSource());
    sl.unregister<MusicPermissionService>();
    sl.registerLazySingleton<MusicPermissionService>(() => _FakeMusicPermissionService());
  });

  testWidgets('splash screen navigates to the home shell', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
          BlocProvider<ThemeModeCubit>.value(value: sl<ThemeModeCubit>()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: AppRouter.router,
        ),
      ),
    );

    expect(find.text('SPMusic'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(MainShellPage), findsOneWidget);
  });
}
