import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/player/domain/entities/playback_status.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';
import 'package:spmusic/features/player/presentation/widgets/now_playing_tile_builder.dart';

import '../bloc/player_cubit_test.dart' show FakePlayerRepository, songA, songB;

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
          home: Column(
            children: [
              for (final song in [songA, songB])
                NowPlayingTileBuilder(
                  songId: song.id,
                  builder: (context, isCurrent, isPlaying) =>
                      Text('${song.id}:$isCurrent:$isPlaying'),
                ),
            ],
          ),
        ),
      );

  testWidgets('flags only the playing song as current and playing', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('1:false:false'), findsOneWidget);
    expect(find.text('2:false:false'), findsOneWidget);

    await tester.runAsync(() async {
      await cubit.playSingle(songA);
      repository.emitStatus(PlaybackStatus.playing);
      // The status stream lives in the real zone; let it deliver the event.
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();

    expect(find.text('1:true:true'), findsOneWidget);
    expect(find.text('2:false:false'), findsOneWidget);
  });

  testWidgets('current but paused is current without playing', (tester) async {
    await tester.pumpWidget(host());
    await tester.runAsync(() async {
      await cubit.playSingle(songA);
      repository.emitStatus(PlaybackStatus.paused);
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();

    expect(find.text('1:true:false'), findsOneWidget);
  });
}
