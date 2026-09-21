import 'package:get_it/get_it.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/library/presentation/bloc/library_cubit.dart';
import '../../features/music/data/datasources/local_music_data_source.dart';
import '../../features/music/data/repositories/music_repository_impl.dart';
import '../../features/music/domain/repositories/music_repository.dart';
import '../../features/player/data/repositories/player_repository_impl.dart';
import '../../features/player/data/services/audio_player_service.dart';
import '../../features/player/data/services/just_audio_player_service.dart';
import '../../features/player/domain/repositories/player_repository.dart';
import '../../features/player/presentation/bloc/player_cubit.dart';
import '../../features/playlist/presentation/bloc/playlist_cubit.dart';
import '../../features/search/presentation/bloc/search_cubit.dart';
import '../../features/spotify/data/datasources/spotify_remote_data_source.dart';
import '../../features/spotify/data/datasources/spotify_remote_data_source_impl.dart';
import '../../features/spotify/data/repositories/spotify_repository_impl.dart';
import '../../features/spotify/data/services/spotify_auth_service.dart';
import '../../features/spotify/data/services/spotify_auth_service_impl.dart';
import '../../features/spotify/domain/repositories/spotify_repository.dart';
import '../../features/spotify/presentation/bloc/spotify_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjector() async {
  sl.registerLazySingleton<LocalMusicDataSource>(() => LocalMusicDataSourceImpl());
  sl.registerLazySingleton<MusicRepository>(() => MusicRepositoryImpl(sl()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl()));

  sl.registerLazySingleton<AudioPlayerService>(() => JustAudioPlayerService());
  sl.registerLazySingleton<PlayerRepository>(() => PlayerRepositoryImpl(sl()));
  sl.registerLazySingleton<PlayerCubit>(() => PlayerCubit(sl()));

  sl.registerFactory<SearchCubit>(() => SearchCubit(sl()));

  sl.registerFactory<LibraryCubit>(() => LibraryCubit(sl()));
  sl.registerFactory<PlaylistCubit>(() => PlaylistCubit(sl()));

  sl.registerLazySingleton<SpotifyAuthService>(() => SpotifyAuthServiceImpl());
  sl.registerLazySingleton<SpotifyRemoteDataSource>(
    () => SpotifyRemoteDataSourceImpl(sl<SpotifyAuthService>().getValidAccessToken),
  );
  sl.registerLazySingleton<SpotifyRepository>(
    () => SpotifyRepositoryImpl(sl(), sl()),
  );
  sl.registerFactory<SpotifyCubit>(() => SpotifyCubit(sl()));
}
