import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_cubit.dart';
import 'features/favorites/presentation/bloc/favorites_cubit.dart';
import 'features/player/presentation/bloc/player_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.spmusic.channel.audio',
    androidNotificationChannelName: 'spmusic playback',
    androidNotificationOngoing: true,
  );
  await setupInjector();
  runApp(const SpMusicApp());
}

class SpMusicApp extends StatelessWidget {
  const SpMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
        BlocProvider<ThemeModeCubit>.value(value: sl<ThemeModeCubit>()),
        BlocProvider<FavoritesCubit>.value(value: sl<FavoritesCubit>()..load()),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          title: 'spmusic',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
