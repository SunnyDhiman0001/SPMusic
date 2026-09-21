import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmusic/core/di/injector.dart';
import 'package:spmusic/core/router/app_router.dart';
import 'package:spmusic/features/home/presentation/pages/main_shell_page.dart';
import 'package:spmusic/features/music/data/datasources/local_music_data_source.dart';
import 'package:spmusic/features/music/data/models/album_model.dart';
import 'package:spmusic/features/music/data/models/artist_model.dart';
import 'package:spmusic/features/music/data/models/playlist_model.dart';
import 'package:spmusic/features/music/data/models/song_model.dart';
import 'package:spmusic/features/music/data/services/music_permission_service.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';

/// The real [LocalMusicDataSourceImpl] and [MusicPermissionServiceImpl] talk
/// to the on_audio_query platform channel, which isn't available in a widget
/// test. Swap them for no-op fakes after `setupInjector` wires the app so the
/// Home/Library cubits can load without throwing a MissingPluginException
/// (which would otherwise leave the UI stuck showing a loading spinner and
/// pumpAndSettle timing out).
class _FakeLocalMusicDataSource implements LocalMusicDataSource {
  @override
  Future<List<SongModel>> getSongs() async => const [];

  @override
  Future<List<ArtistModel>> getArtists() async => const [];

  @override
  Future<List<AlbumModel>> getAlbums() async => const [];

  @override
  Future<List<PlaylistModel>> getPlaylists() async => const [];

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

    sl.unregister<LocalMusicDataSource>();
    sl.registerLazySingleton<LocalMusicDataSource>(() => _FakeLocalMusicDataSource());

    sl.unregister<MusicPermissionService>();
    sl.registerLazySingleton<MusicPermissionService>(() => _FakeMusicPermissionService());
  });

  testWidgets('router starts at /splash and navigates to /home shell', (tester) async {
    final router = AppRouter.router;
    await tester.pumpWidget(
      BlocProvider<PlayerCubit>.value(
        value: sl<PlayerCubit>(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );

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
