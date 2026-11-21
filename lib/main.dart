import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/equalizer/presentation/bloc/equalizer_cubit.dart';
import 'features/favorites/presentation/bloc/favorites_cubit.dart';
import 'features/player/data/services/just_audio_player_service.dart';
import 'features/player/presentation/bloc/media_session_binder.dart';
import 'features/player/presentation/bloc/player_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  // One media session (notification + lock screen) for the whole app.
  await MediaSessionBinder(
    session: sl<JustAudioPlayerService>(),
    player: sl<PlayerCubit>(),
    favorites: sl<FavoritesCubit>(),
  ).start();
  runApp(const SpMusicApp());
  // Android 13+ hides the playback notification (some OEMs, e.g. Infinix,
  // even for media style) until this is granted. Needs a live Activity, so
  // ask after the first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) => _requestNotificationPermission());
}

Future<void> _requestNotificationPermission() async {
  if (!Platform.isAndroid) return;
  try {
    final status = await Permission.notification.status;
    if (status.isDenied) await Permission.notification.request();
  } catch (_) {
    // Never block startup on a permission prompt.
  }
}

class SpMusicApp extends StatelessWidget {
  const SpMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
        BlocProvider<EqualizerCubit>.value(value: sl<EqualizerCubit>()),
        BlocProvider<FavoritesCubit>.value(value: sl<FavoritesCubit>()..load()),
      ],
      child: MaterialApp.router(
        title: 'spmusic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
