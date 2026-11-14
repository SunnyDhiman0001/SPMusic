import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/glow_button.dart';
import 'package:spmusic/features/home/presentation/widgets/shuffle_all_button.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';

import '../../../player/presentation/bloc/player_cubit_test.dart'
    show FakePlayerRepository, songA, songB;

void main() {
  late FakePlayerRepository repository;
  late PlayerCubit cubit;

  setUp(() {
    repository = FakePlayerRepository();
    cubit = PlayerCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  Widget host() => BlocProvider<PlayerCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(
            body: Center(child: ShuffleAllButton(songs: [songA, songB])),
          ),
        ),
      );

  testWidgets('is shown before anything is playing', (tester) async {
    await tester.pumpWidget(host());

    expect(find.byType(GlowButton), findsOneWidget);
  });

  testWidgets('tapping it starts shuffled playback of the whole list', (tester) async {
    await tester.pumpWidget(host());

    await tester.runAsync(() async {
      await tester.tap(find.byType(GlowButton));
      await Future<void>.delayed(const Duration(milliseconds: 900));
    });

    expect(cubit.state.queue, [songA, songB]);
    expect(cubit.state.isShuffle, isTrue);
  });

  testWidgets('disappears once a song is playing', (tester) async {
    await tester.pumpWidget(host());
    expect(find.byType(GlowButton), findsOneWidget);

    await tester.runAsync(() => cubit.playSingle(songA));
    await tester.pump();
    // The button animates out rather than vanishing instantly.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GlowButton), findsNothing);
  });
}
