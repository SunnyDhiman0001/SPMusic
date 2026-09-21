import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/spotify/domain/entities/spotify_playlist_entity.dart';
import 'package:spmusic/features/spotify/domain/entities/spotify_track_entity.dart';
import 'package:spmusic/features/spotify/domain/entities/spotify_user_entity.dart';
import 'package:spmusic/features/spotify/domain/repositories/spotify_repository.dart';
import 'package:spmusic/features/spotify/presentation/bloc/spotify_cubit.dart';
import 'package:spmusic/features/spotify/presentation/bloc/spotify_state.dart';

class _FakeSpotifyRepository implements SpotifyRepository {
  bool connected = false;
  bool failConnect = false;
  bool failSearch = false;
  List<SpotifyTrackEntity> searchResults = const [];
  SpotifyPlaylistEntity? playlistToReturn;

  @override
  Future<bool> isConnected() async => connected;

  @override
  Future<void> connect() async {
    if (failConnect) throw Exception('connect failed');
    connected = true;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  @override
  Future<SpotifyUserEntity> getCurrentUser() async => _user;

  @override
  Future<List<SpotifyTrackEntity>> searchTracks(String query) async {
    if (failSearch) throw Exception('search failed');
    return searchResults;
  }

  @override
  Future<SpotifyPlaylistEntity> createPlaylistFromTracks({
    required String name,
    required String description,
    required List<String> trackUris,
  }) async {
    return playlistToReturn!;
  }
}

const _user = SpotifyUserEntity(id: 'u1', displayName: 'Sunny', email: 'sunny@example.com');

const _tracks = [
  SpotifyTrackEntity(
    id: 't1',
    uri: 'spotify:track:t1',
    name: 'Song One',
    artistNames: 'Artist A',
    albumArtUrl: 'https://img/one.jpg',
  ),
];

const _playlist = SpotifyPlaylistEntity(
  id: 'pl1',
  name: 'My Search Playlist',
  embedUrl: 'https://open.spotify.com/embed/playlist/pl1?utm_source=generator&theme=0',
);

void main() {
  late _FakeSpotifyRepository repository;

  setUp(() {
    repository = _FakeSpotifyRepository();
  });

  group('checkConnection', () {
    blocTest<SpotifyCubit, SpotifyState>(
      'emits SpotifyDisconnected when not connected',
      build: () => SpotifyCubit(repository),
      act: (cubit) => cubit.checkConnection(),
      expect: () => [const SpotifyDisconnected()],
    );

    blocTest<SpotifyCubit, SpotifyState>(
      'emits SpotifyConnectedIdle with the current user when connected',
      build: () {
        repository.connected = true;
        return SpotifyCubit(repository);
      },
      act: (cubit) => cubit.checkConnection(),
      expect: () => [const SpotifyConnectedIdle(_user)],
    );
  });

  group('connectAndShowSearch', () {
    blocTest<SpotifyCubit, SpotifyState>(
      'emits [SpotifyConnecting, SpotifyConnectedIdle] on success',
      build: () => SpotifyCubit(repository),
      act: (cubit) => cubit.connectAndShowSearch(),
      expect: () => [const SpotifyConnecting(), const SpotifyConnectedIdle(_user)],
    );

    blocTest<SpotifyCubit, SpotifyState>(
      'emits [SpotifyConnecting, SpotifyError] on failure',
      build: () {
        repository.failConnect = true;
        return SpotifyCubit(repository);
      },
      act: (cubit) => cubit.connectAndShowSearch(),
      expect: () => [const SpotifyConnecting(), isA<SpotifyError>()],
    );
  });

  group('search', () {
    blocTest<SpotifyCubit, SpotifyState>(
      'emits SpotifySearchResults with matching tracks for a non-empty query',
      build: () {
        repository.searchResults = _tracks;
        return SpotifyCubit(repository);
      },
      seed: () => const SpotifyConnectedIdle(_user),
      act: (cubit) => cubit.search('some song'),
      expect: () => [const SpotifySearchResults(_user, _tracks)],
    );

    blocTest<SpotifyCubit, SpotifyState>(
      'emits SpotifyConnectedIdle for an empty query',
      build: () => SpotifyCubit(repository),
      seed: () => const SpotifySearchResults(_user, _tracks),
      act: (cubit) => cubit.search(''),
      expect: () => [const SpotifyConnectedIdle(_user)],
    );

    blocTest<SpotifyCubit, SpotifyState>(
      'emits SpotifyError on failure',
      build: () {
        repository.failSearch = true;
        return SpotifyCubit(repository);
      },
      seed: () => const SpotifyConnectedIdle(_user),
      act: (cubit) => cubit.search('some song'),
      expect: () => [isA<SpotifyError>()],
    );

    blocTest<SpotifyCubit, SpotifyState>(
      'does nothing when not connected',
      build: () => SpotifyCubit(repository),
      act: (cubit) => cubit.search('some song'),
      expect: () => const <SpotifyState>[],
    );
  });

  group('createPlaylist', () {
    blocTest<SpotifyCubit, SpotifyState>(
      'emits [SpotifyPlaylistCreating, SpotifyPlaylistReady] from a search results state',
      build: () {
        repository.playlistToReturn = _playlist;
        return SpotifyCubit(repository);
      },
      seed: () => const SpotifySearchResults(_user, _tracks),
      act: (cubit) => cubit.createPlaylist(),
      expect: () => [
        const SpotifyPlaylistCreating(_tracks),
        const SpotifyPlaylistReady(_playlist),
      ],
    );
  });
}
