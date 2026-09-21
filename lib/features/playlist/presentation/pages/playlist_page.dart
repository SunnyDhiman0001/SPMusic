import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/di/injector.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/playlist_cubit.dart';
import '../bloc/playlist_state.dart';
import '../widgets/playlist_header.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({required this.playlistId, super.key});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlaylistCubit>()..loadPlaylist(playlistId),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<PlaylistCubit, PlaylistState>(
          builder: (context, state) {
            return switch (state) {
              PlaylistLoading() => const Center(child: CircularProgressIndicator()),
              PlaylistError(:final message) => Center(child: Text('Something went wrong: $message')),
              PlaylistLoaded(:final playlist, :final songs) => CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PlaylistHeader(
                        playlist: playlist,
                        songCount: songs.length,
                        onPlay: () => context.read<PlayerCubit>().playQueue(songs),
                        onShuffle: () {
                          context.read<PlayerCubit>()
                            ..playQueue(songs)
                            ..toggleShuffle();
                        },
                      ),
                    ),
                    SliverList.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SearchSongTile(
                          song: song,
                          onTap: () => context.read<PlayerCubit>().playQueue(songs, startIndex: index),
                          trailing: IconButton(
                            icon: Icon(
                              LucideIcons.heart,
                              color: song.isFavorite ? Theme.of(context).colorScheme.secondary : null,
                            ),
                            onPressed: () => context.read<PlaylistCubit>().toggleFavorite(song.id),
                          ),
                        ).animate().fadeIn(delay: (30 * index).ms, duration: 200.ms);
                      },
                    ),
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}
