import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/di/injector.dart';
import '../../../search/presentation/widgets/search_input_bar.dart';
import '../../domain/entities/spotify_track_entity.dart';
import '../../domain/entities/spotify_user_entity.dart';
import '../bloc/spotify_cubit.dart';
import '../bloc/spotify_state.dart';

class SpotifyPage extends StatelessWidget {
  const SpotifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SpotifyCubit>()..checkConnection(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Spotify')),
        body: BlocBuilder<SpotifyCubit, SpotifyState>(
          builder: (context, state) {
            final showSearchBar =
                state is SpotifyConnectedIdle || state is SpotifySearchResults;
            final connectedUser = switch (state) {
              SpotifyConnectedIdle(:final user) => user,
              SpotifySearchResults(:final user) => user,
              _ => null,
            };
            return Column(
              children: [
                if (connectedUser != null) _ConnectedUserBanner(user: connectedUser),
                if (showSearchBar) _buildSearchBar(context),
                Expanded(
                  child: switch (state) {
                    SpotifyDisconnected() => const _DisconnectedView(),
                    SpotifyConnecting() =>
                      const _LoadingView(message: 'Connecting to Spotify...'),
                    SpotifyConnectedIdle() => const _SearchPromptView(),
                    SpotifySearchResults(:final tracks) => _SearchResultsView(tracks: tracks),
                    SpotifyPlaylistCreating() =>
                      const _LoadingView(message: 'Creating playlist...'),
                    SpotifyPlaylistReady(:final playlist) => _PlaylistReadyView(
                        name: playlist.name,
                        embedUrl: playlist.embedUrl,
                      ),
                    SpotifyError(:final message) => _ErrorView(message: message),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SearchInputBar(
      onChanged: (query) => context.read<SpotifyCubit>().search(query),
    );
  }
}

class _ConnectedUserBanner extends StatelessWidget {
  const _ConnectedUserBanner({required this.user});

  final SpotifyUserEntity user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connected as ${user.displayName}', style: Theme.of(context).textTheme.titleSmall),
          if (user.email.isNotEmpty)
            SelectableText(
              user.email,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _DisconnectedView extends StatelessWidget {
  const _DisconnectedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => context.read<SpotifyCubit>().connectAndShowSearch(),
        icon: const Icon(Icons.podcasts),
        label: const Text('Connect Spotify'),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Something went wrong: $message', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<SpotifyCubit>().checkConnection(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPromptView extends StatelessWidget {
  const _SearchPromptView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Search for tracks to build a playlist', textAlign: TextAlign.center),
      ),
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({required this.tracks});

  final List<SpotifyTrackEntity> tracks;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Center(child: Text('No tracks found'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: track.albumArtUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: track.albumArtUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(width: 48, height: 48),
                ),
                title: Text(track.name),
                subtitle: Text(track.artistNames),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () => context.read<SpotifyCubit>().createPlaylist(),
              child: const Text('Create Playlist From These'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistReadyView extends StatefulWidget {
  const _PlaylistReadyView({required this.name, required this.embedUrl});

  final String name;
  final String embedUrl;

  @override
  State<_PlaylistReadyView> createState() => _PlaylistReadyViewState();
}

class _PlaylistReadyViewState extends State<_PlaylistReadyView> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(widget.embedUrl));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(widget.name, style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(child: WebViewWidget(controller: _controller)),
      ],
    );
  }
}
