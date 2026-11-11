import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/equalizer/data/services/equalizer_service.dart';
import '../../features/equalizer/presentation/bloc/equalizer_cubit.dart';
import '../../features/folders/data/repositories/folder_repository_impl.dart';
import '../../features/folders/data/services/folder_filter.dart';
import '../../features/folders/domain/repositories/folder_repository.dart';
import '../../features/folders/presentation/bloc/folders_cubit.dart';
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
import '../utils/library_change_notifier.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjector() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageServiceImpl(sl()));
  sl.registerLazySingleton<MusicPermissionService>(() => MusicPermissionServiceImpl());
  sl.registerLazySingleton<ThemeModeCubit>(() => ThemeModeCubit(sl()));

  sl.registerLazySingleton<LocalMusicDataSource>(() => LocalMusicDataSourceImpl());
  sl.registerLazySingleton<LibraryChangeNotifier>(() => LibraryChangeNotifier());
  sl.registerLazySingleton<FolderFilter>(() => FolderFilter(sl()));
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(sl(), sl(), folderFilter: sl<FolderFilter>()),
  );
  sl.registerLazySingleton<FolderRepository>(() => FolderRepositoryImpl(sl(), sl(), sl()));
  sl.registerFactory<FoldersCubit>(() => FoldersCubit(sl(), sl()));
  sl.registerFactory<FolderSongsCubit>(() => FolderSongsCubit(sl()));
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(sl(), sl(), libraryChanges: sl<LibraryChangeNotifier>().changes),
  );
  // A real singleton (not a factory): every screen must share one instance
  // so a favorite toggled anywhere updates everywhere immediately. Load()
  // is triggered by whoever first reads it (see main.dart), not eagerly
  // here, so its first MediaStore access happens after DI/test setup is
  // fully wired rather than mid-registration.
  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(sl(), libraryChanges: sl<LibraryChangeNotifier>().changes),
  );

  // One engine instance backs playback and the equalizer, since the
  // equalizer is an effect attached to that player's audio pipeline.
  sl.registerLazySingleton<JustAudioPlayerService>(() => JustAudioPlayerService());
  sl.registerLazySingleton<AudioPlayerService>(() => sl<JustAudioPlayerService>());
  sl.registerLazySingleton<EqualizerService>(() => sl<JustAudioPlayerService>());
  sl.registerLazySingleton<EqualizerCubit>(() => EqualizerCubit(sl(), sl()));
  sl.registerLazySingleton<PlayerRepository>(() => PlayerRepositoryImpl(sl()));
  sl.registerLazySingleton<PlayerCubit>(
    () => PlayerCubit(sl(), onPlaybackStarted: sl<MusicRepository>().recordPlayed),
  );

  sl.registerFactory<SearchCubit>(() => SearchCubit(sl()));

  sl.registerFactory<PlaylistCubit>(() => PlaylistCubit(sl()));
}
