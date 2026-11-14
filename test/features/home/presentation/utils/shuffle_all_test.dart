import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/home/presentation/utils/shuffle_all.dart';
import 'package:spmusic/features/player/presentation/bloc/player_cubit.dart';

import '../../../player/presentation/bloc/player_cubit_test.dart'
    show FakePlayerRepository, songA, songB;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('queues every song, starts at a random one and turns shuffle on', () async {
    await shuffleAll(cubit, [songA, songB], random: Random(42));

    expect(cubit.state.queue, [songA, songB]);
    expect(cubit.state.currentIndex, Random(42).nextInt(2));
    expect(cubit.state.isShuffle, isTrue);
  });

  test('leaves shuffle on when it was already on (never toggles it off)', () async {
    await cubit.toggleShuffle();
    expect(cubit.state.isShuffle, isTrue);

    await shuffleAll(cubit, [songA, songB], random: Random(1));

    expect(cubit.state.isShuffle, isTrue);
  });

  test('does nothing for an empty library', () async {
    await shuffleAll(cubit, const []);

    expect(cubit.state.queue, isEmpty);
    expect(cubit.state.isShuffle, isFalse);
  });
}
