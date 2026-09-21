import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/music/data/datasources/local_music_data_source.dart';
import '../../features/music/data/repositories/music_repository_impl.dart';
import '../../features/music/data/services/local_storage_service.dart';
import '../../features/music/data/services/music_permission_service.dart';
import '../../features/music/domain/repositories/music_repository.dart';
import '../../features/player/data/repositories/player_repository_impl.dart';
import '../../features/player/data/services/audio_player_service.dart';
import '../../features/player/data/services/just_audio_player_service.dart';
import '../../features/player/domain/repositories/player_repository.dart';
import '../../features/player/presentation/bloc/player_cubit.dart';
import '../../features/playlist/presentation/bloc/playlist_cubit.dart';
import '../../features/search/presentation/bloc/search_cubit.dart';
import '../theme/theme_mode_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjector() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageServiceImpl(sl()));
  sl.registerLazySingleton<MusicPermissionService>(() => MusicPermissionServiceImpl());
  sl.registerLazySingleton<ThemeModeCubit>(() => ThemeModeCubit(sl()));

  sl.registerLazySingleton<LocalMusicDataSource>(() => LocalMusicDataSourceImpl());
  sl.registerLazySingleton<MusicRepository>(() => MusicRepositoryImpl(sl(), sl()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl(), sl()));
  // A real singleton (not a factory): every screen must share one instance
  // so a favorite toggled anywhere updates everywhere immediately. Load()
  // is triggered by whoever first reads it (see main.dart), not eagerly
  // here, so its first MediaStore access happens after DI/test setup is
  // fully wired rather than mid-registration.
  sl.registerLazySingleton<FavoritesCubit>(() => FavoritesCubit(sl()));

  sl.registerLazySingleton<AudioPlayerService>(() => JustAudioPlayerService());
  sl.registerLazySingleton<PlayerRepository>(() => PlayerRepositoryImpl(sl()));
  sl.registerLazySingleton<PlayerCubit>(
    () => PlayerCubit(sl(), onPlaybackStarted: sl<MusicRepository>().recordPlayed),
  );

  sl.registerFactory<SearchCubit>(() => SearchCubit(sl()));

  sl.registerFactory<PlaylistCubit>(() => PlaylistCubit(sl()));
}
