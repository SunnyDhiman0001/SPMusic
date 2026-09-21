import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/card_display_item.dart';
import '../../../../core/widgets/horizontal_card_list.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../music/domain/entities/album_entity.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../widgets/recent_searches_list.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/search_song_tile.dart';

CardDisplayItem _artistToCard(ArtistEntity artist) => CardDisplayItem(
      id: artist.id,
      artworkKind: ArtworkKind.none,
      title: artist.name,
      subtitle: '${artist.trackCount} tracks',
    );

CardDisplayItem _albumToCard(AlbumEntity album) => CardDisplayItem(
      id: album.id,
      artworkKind: ArtworkKind.album,
      artworkId: int.tryParse(album.id),
      title: album.title,
      subtitle: album.artistName,
    );

CardDisplayItem _playlistToCard(PlaylistEntity playlist) => CardDisplayItem(
      id: playlist.id,
      artworkKind: ArtworkKind.none,
      title: playlist.name,
      subtitle: playlist.creator,
    );

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

/// Owns the search text field's controller/focus/debounce state via hooks,
/// so no StatefulWidget is needed for what is otherwise plain local UI
/// state (see [SearchInputBar], which is purely presentational).
class _SearchView extends HookWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);

    // Rebuild whenever the text or focus state changes, so the clear
    // button and the focus border stay in sync.
    useValueListenable(controller);
    useListenable(focusNode);

    useEffect(() => () => debounceTimer.value?.cancel(), const []);

    void search(String query) => context.read<SearchCubit>().search(query);

    void handleTextChanged(String value) {
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(const Duration(milliseconds: 300), () => search(value));
    }

    void handleRecentSearchTap(String query) {
      debounceTimer.value?.cancel();
      controller.text = query;
      controller.selection = TextSelection.collapsed(offset: query.length);
      search(query);
    }

    void handleClear() {
      debounceTimer.value?.cancel();
      controller.clear();
      search('');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            SearchInputBar(
              controller: controller,
              focusNode: focusNode,
              hasText: controller.text.isNotEmpty,
              onTextChanged: handleTextChanged,
              onClear: handleClear,
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchIdle() => RecentSearchesList(
                        searches: state.recentSearches,
                        onTapSearch: handleRecentSearchTap,
                        onClear: () => context.read<SearchCubit>().clearRecentSearches(),
                      ),
                    SearchLoading() => const Center(child: CircularProgressIndicator()),
                    SearchError() => Center(child: Text(state.message)),
                    SearchLoaded() when state.results.isEmpty =>
                      const Center(child: Text('No results found')),
                    SearchLoaded() => _SearchResultsList(results: state.results),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.results});

  final SearchResults results;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (results.songs.isNotEmpty) ...[
          const SectionHeader(title: 'Songs'),
          for (var i = 0; i < results.songs.length; i++)
            SearchSongTile(
              song: results.songs[i],
              onTap: () => context.read<PlayerCubit>().playSingle(results.songs[i]),
            ).animate().fadeIn(delay: (30 * i).ms, duration: 200.ms),
          const SizedBox(height: AppSpacing.md),
        ],
        if (results.artists.isNotEmpty) ...[
          const SectionHeader(title: 'Artists'),
          HorizontalCardList(
            items: results.artists.map(_artistToCard).toList(),
            isCircle: true,
          ).animate().fadeIn(delay: 0.ms, duration: 250.ms),
          const SizedBox(height: AppSpacing.md),
        ],
        if (results.albums.isNotEmpty) ...[
          const SectionHeader(title: 'Albums'),
          HorizontalCardList(items: results.albums.map(_albumToCard).toList())
              .animate()
              .fadeIn(delay: 80.ms, duration: 250.ms),
          const SizedBox(height: AppSpacing.md),
        ],
        if (results.playlists.isNotEmpty) ...[
          const SectionHeader(title: 'Playlists'),
          HorizontalCardList(items: results.playlists.map(_playlistToCard).toList())
              .animate()
              .fadeIn(delay: 160.ms, duration: 250.ms),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
