import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/card_display_item.dart';
import '../../../../core/widgets/horizontal_card_list.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../search/presentation/widgets/search_song_tile.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import '../widgets/library_filter_chips.dart';

CardDisplayItem _playlistToCard(PlaylistEntity playlist) => CardDisplayItem(
      id: playlist.id,
      imageUrl: playlist.coverUrl,
      title: playlist.name,
      subtitle: playlist.description,
    );

CardDisplayItem _albumToCard(AlbumEntity album) => CardDisplayItem(
      id: album.id,
      imageUrl: album.coverUrl,
      title: album.title,
      subtitle: album.artistName,
    );

CardDisplayItem _artistToCard(ArtistEntity artist) => CardDisplayItem(
      id: artist.id,
      imageUrl: artist.imageUrl,
      title: artist.name,
      subtitle: 'Artist',
    );

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LibraryCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          actions: [
            IconButton(
              icon: const Icon(Icons.podcasts),
              tooltip: 'Connect Spotify',
              onPressed: () => context.push('/spotify'),
            ),
          ],
        ),
        body: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            return switch (state) {
              LibraryLoading() => const Center(child: CircularProgressIndicator()),
              LibraryError(:final message) => Center(child: Text('Something went wrong: $message')),
              LibraryLoaded() => _LibraryContent(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent({required this.state});

  final LibraryLoaded state;

  @override
  Widget build(BuildContext context) {
    final filter = state.filter;
    final showAll = filter == LibraryFilter.all;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        LibraryFilterChips(
          selected: filter,
          onSelected: (value) => context.read<LibraryCubit>().setFilter(value),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: ListView(
              key: ValueKey(filter),
              children: [
                if (showAll || filter == LibraryFilter.playlists) ...[
                  const SectionHeader(title: 'Playlists'),
                  HorizontalCardList(
                    items: state.playlists.map(_playlistToCard).toList(),
                    onItemTap: (id) => context.push('/playlist/$id'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (showAll || filter == LibraryFilter.albums) ...[
                  const SectionHeader(title: 'Albums'),
                  HorizontalCardList(items: state.albums.map(_albumToCard).toList()),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (showAll || filter == LibraryFilter.artists) ...[
                  const SectionHeader(title: 'Artists'),
                  HorizontalCardList(
                    items: state.artists.map(_artistToCard).toList(),
                    isCircle: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (showAll || filter == LibraryFilter.songs) ...[
                  if (state.likedSongs.isNotEmpty) ...[
                    const SectionHeader(title: 'Liked Songs'),
                    _SongList(songs: state.likedSongs),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.recentlyPlayed.isNotEmpty) ...[
                    const SectionHeader(title: 'Recently Played'),
                    _SongList(songs: state.recentlyPlayed),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SongList extends StatelessWidget {
  const _SongList({required this.songs});

  final List<SongEntity> songs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final song in songs)
          SearchSongTile(
            song: song,
            onTap: () => context.read<PlayerCubit>().playSingle(song),
          ),
      ],
    );
  }
}
