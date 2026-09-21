import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/features/spotify/data/datasources/spotify_remote_data_source.dart';
import 'package:spmusic/features/spotify/data/repositories/spotify_repository_impl.dart';
import 'package:spmusic/features/spotify/data/services/spotify_auth_service.dart';

class _FakeAuthService implements SpotifyAuthService {
  bool connected = false;
  int loginCalls = 0;
  int logoutCalls = 0;

  @override
  Future<bool> hasValidSession() async => connected;

  @override
  Future<void> login() async {
    loginCalls++;
    connected = true;
  }

  @override
  Future<String> getValidAccessToken() async => 'token';

  @override
  Future<void> logout() async {
    logoutCalls++;
    connected = false;
  }
}

class _FakeRemoteDataSource implements SpotifyRemoteDataSource {
  List<Map<String, dynamic>> searchTracksResponse = const [];
  Map<String, dynamic> createPlaylistResponse = const {};
  Map<String, dynamic> currentUserResponse = const {};
  final List<String> callOrder = [];
  String? addedPlaylistId;
  List<String>? addedUris;

  @override
  Future<Map<String, dynamic>> getCurrentUser() async => currentUserResponse;

  @override
  Future<List<Map<String, dynamic>>> searchTracks(String query, {int limit = 10}) async {
    callOrder.add('searchTracks');
    return searchTracksResponse;
  }

  @override
  Future<Map<String, dynamic>> createPlaylist(String name, String description) async {
    callOrder.add('createPlaylist');
    return createPlaylistResponse;
  }

  @override
  Future<void> addTracksToPlaylist(String playlistId, List<String> uris) async {
    callOrder.add('addTracksToPlaylist');
    addedPlaylistId = playlistId;
    addedUris = uris;
  }
}

void main() {
  late _FakeAuthService authService;
  late _FakeRemoteDataSource remote;
  late SpotifyRepositoryImpl repository;

  setUp(() {
    authService = _FakeAuthService();
    remote = _FakeRemoteDataSource();
    repository = SpotifyRepositoryImpl(authService, remote);
  });

  test('isConnected delegates to the auth service', () async {
    authService.connected = true;
    expect(await repository.isConnected(), isTrue);
  });

  test('connect delegates to the auth service', () async {
    await repository.connect();
    expect(authService.loginCalls, 1);
  });

  test('disconnect delegates to the auth service', () async {
    authService.connected = true;
    await repository.disconnect();
    expect(authService.logoutCalls, 1);
    expect(authService.connected, isFalse);
  });

  test('getCurrentUser maps raw JSON correctly to entity', () async {
    remote.currentUserResponse = {
      'id': 'u1',
      'display_name': 'Sunny',
      'email': 'sunny@example.com',
    };

    final user = await repository.getCurrentUser();

    expect(user.id, 'u1');
    expect(user.displayName, 'Sunny');
    expect(user.email, 'sunny@example.com');
  });

  test('getCurrentUser falls back to defaults when display_name/email are missing', () async {
    remote.currentUserResponse = {'id': 'u1'};

    final user = await repository.getCurrentUser();

    expect(user.displayName, 'Spotify User');
    expect(user.email, '');
  });

  test('searchTracks maps raw JSON correctly to entities', () async {
    remote.searchTracksResponse = [
      {
        'id': 't1',
        'uri': 'spotify:track:t1',
        'name': 'Song One',
        'artists': [
          {'name': 'Artist A'},
          {'name': 'Artist B'},
        ],
        'album': {
          'images': [
            {'url': 'https://img/one.jpg'},
          ],
        },
      },
    ];

    final tracks = await repository.searchTracks('some song');

    expect(tracks, hasLength(1));
    expect(tracks.first.id, 't1');
    expect(tracks.first.uri, 'spotify:track:t1');
    expect(tracks.first.name, 'Song One');
    expect(tracks.first.artistNames, 'Artist A, Artist B');
    expect(tracks.first.albumArtUrl, 'https://img/one.jpg');
  });

  test('createPlaylistFromTracks calls create-then-add-tracks in order and returns correct embedUrl', () async {
    remote.createPlaylistResponse = {'id': 'pl1', 'name': 'My Playlist'};

    final playlist = await repository.createPlaylistFromTracks(
      name: 'My Playlist',
      description: 'desc',
      trackUris: ['spotify:track:t1', 'spotify:track:t2'],
    );

    expect(remote.callOrder, ['createPlaylist', 'addTracksToPlaylist']);
    expect(remote.addedPlaylistId, 'pl1');
    expect(remote.addedUris, ['spotify:track:t1', 'spotify:track:t2']);
    expect(playlist.id, 'pl1');
    expect(playlist.name, 'My Playlist');
    expect(
      playlist.embedUrl,
      'https://open.spotify.com/embed/playlist/pl1?utm_source=generator&theme=0',
    );
  });
}
