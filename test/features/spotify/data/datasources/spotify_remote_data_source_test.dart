import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spmusic/features/spotify/data/datasources/spotify_remote_data_source.dart';
import 'package:spmusic/features/spotify/data/datasources/spotify_remote_data_source_impl.dart';

void main() {
  group('SpotifyRemoteDataSourceImpl', () {
    Future<String> tokenProvider() async => 'fake-access-token';

    test('getCurrentUser GETs /v1/me and returns the parsed user JSON', () async {
      late Uri capturedUri;
      late String capturedAuthHeader;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedAuthHeader = request.headers['Authorization'] ?? '';
        return http.Response(
          jsonEncode({'id': 'u1', 'display_name': 'Sunny', 'email': 'sunny@example.com'}),
          200,
        );
      });

      final SpotifyRemoteDataSource dataSource =
          SpotifyRemoteDataSourceImpl(tokenProvider, httpClient: client);

      final result = await dataSource.getCurrentUser();

      expect(capturedUri.toString(), 'https://api.spotify.com/v1/me');
      expect(capturedAuthHeader, 'Bearer fake-access-token');
      expect(result['id'], 'u1');
      expect(result['display_name'], 'Sunny');
      expect(result['email'], 'sunny@example.com');
    });

    test('searchTracks parses tracks.items array from the response', () async {
      late Uri capturedUri;
      late String capturedAuthHeader;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedAuthHeader = request.headers['Authorization'] ?? '';
        return http.Response(
          jsonEncode({
            'tracks': {
              'items': [
                {'id': 't1', 'uri': 'spotify:track:t1', 'name': 'Song One'},
                {'id': 't2', 'uri': 'spotify:track:t2', 'name': 'Song Two'},
              ],
            },
          }),
          200,
        );
      });

      final SpotifyRemoteDataSource dataSource =
          SpotifyRemoteDataSourceImpl(tokenProvider, httpClient: client);

      final result = await dataSource.searchTracks('some song');

      expect(result, hasLength(2));
      expect(result.first['id'], 't1');
      expect(capturedUri.toString(), contains('/v1/search'));
      expect(capturedUri.queryParameters['q'], 'some song');
      expect(capturedUri.queryParameters['type'], 'track');
      expect(capturedUri.queryParameters['limit'], '10');
      expect(capturedAuthHeader, 'Bearer fake-access-token');
    });

    test('searchTracks returns [] without making a network call for an empty query', () async {
      var callCount = 0;

      final client = MockClient((request) async {
        callCount++;
        return http.Response('nope', 500);
      });

      final SpotifyRemoteDataSource dataSource =
          SpotifyRemoteDataSourceImpl(tokenProvider, httpClient: client);

      final result = await dataSource.searchTracks('');

      expect(result, isEmpty);
      expect(callCount, 0);
    });

    test('createPlaylist POSTs the right JSON body and returns the parsed playlist', () async {
      late Uri capturedUri;
      late Map<String, dynamic> capturedBody;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'id': 'pl1', 'name': 'My Playlist'}),
          201,
        );
      });

      final SpotifyRemoteDataSource dataSource =
          SpotifyRemoteDataSourceImpl(tokenProvider, httpClient: client);

      final result = await dataSource.createPlaylist('My Playlist', 'A description');

      expect(capturedUri.toString(), 'https://api.spotify.com/v1/me/playlists');
      expect(capturedBody['name'], 'My Playlist');
      expect(capturedBody['description'], 'A description');
      expect(capturedBody['public'], false);
      expect(result['id'], 'pl1');
    });

    test('addTracksToPlaylist POSTs to the right URL with the right body', () async {
      late Uri capturedUri;
      late Map<String, dynamic> capturedBody;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 201);
      });

      final SpotifyRemoteDataSource dataSource =
          SpotifyRemoteDataSourceImpl(tokenProvider, httpClient: client);

      await dataSource.addTracksToPlaylist('pl1', ['spotify:track:t1', 'spotify:track:t2']);

      expect(capturedUri.toString(), 'https://api.spotify.com/v1/playlists/pl1/tracks');
      expect(capturedBody['uris'], ['spotify:track:t1', 'spotify:track:t2']);
    });

    test('throws on non-2xx response', () async {
      final client = MockClient((request) async {
        return http.Response('nope', 401);
      });

      final SpotifyRemoteDataSource dataSource =
          SpotifyRemoteDataSourceImpl(tokenProvider, httpClient: client);

      expect(() => dataSource.searchTracks('song'), throwsA(isA<Exception>()));
    });
  });
}
