import 'dart:math';

import '../../../music/domain/entities/song_entity.dart';
import '../../../player/presentation/bloc/player_cubit.dart';

/// Home shuffle button: plays [songs] starting at a random one with shuffle
/// on. Uses only the public [PlayerCubit] API (same order as the playlist
/// page's shuffle: start playback, then enable shuffle if it is off), and
/// never toggles shuffle *off*.
Future<void> shuffleAll(PlayerCubit cubit, List<SongEntity> songs, {Random? random}) async {
  if (songs.isEmpty) return;
  final start = (random ?? Random()).nextInt(songs.length);
  final playing = cubit.playQueue(songs, startIndex: start);
  if (!cubit.state.isShuffle) await cubit.toggleShuffle();
  await playing;
}
