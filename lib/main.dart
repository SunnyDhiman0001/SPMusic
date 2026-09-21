import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/player/presentation/bloc/player_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const SpMusicApp());
}

class SpMusicApp extends StatelessWidget {
  const SpMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerCubit>.value(
      value: sl<PlayerCubit>(),
      child: MaterialApp.router(
        title: 'spmusic',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
