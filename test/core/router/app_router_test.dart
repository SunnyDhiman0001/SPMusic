import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/di/injector.dart';
import 'package:spmusic/core/router/app_router.dart';
import 'package:spmusic/features/home/presentation/pages/main_shell_page.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await setupInjector();
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
