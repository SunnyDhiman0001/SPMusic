import 'dart:convert';

import 'package:http/http.dart' as http;

import 'spotify_remote_data_source.dart';

typedef AccessTokenProvider = Future<String> Function();

/// Talks to the Spotify Web API. Depends only on an [AccessTokenProvider]
/// callback (not on [SpotifyAuthServiceImpl] directly) so it stays testable
/// with a fake token provider and [MockClient].
class SpotifyRemoteDataSourceImpl implements SpotifyRemoteDataSource {
  SpotifyRemoteDataSourceImpl(this._getAccessToken, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'https://api.spotify.com/v1';

  final AccessTokenProvider _getAccessToken;
  final http.Client _httpClient;

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final uri = Uri.parse('$_baseUrl/me');
    final response = await _httpClient.get(uri, headers: await _authHeaders());
    _throwIfNotOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> searchTracks(String query, {int limit = 10}) async {
    if (query.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': query,
      'type': 'track',
      'limit': '$limit',
    });

    final response = await _httpClient.get(uri, headers: await _authHeaders());
    _throwIfNotOk(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['tracks']['items'] as List;
    return items.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createPlaylist(String name, String description) async {
    final uri = Uri.parse('$_baseUrl/me/playlists');

    final response = await _httpClient.post(
      uri,
      headers: {
        ...await _authHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'public': false,
      }),
    );
    _throwIfNotOk(response);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<void> addTracksToPlaylist(String playlistId, List<String> uris) async {
    final uri = Uri.parse('$_baseUrl/playlists/$playlistId/tracks');

    final response = await _httpClient.post(
      uri,
      headers: {
        ...await _authHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'uris': uris}),
    );
    _throwIfNotOk(response);
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getAccessToken();
    return {'Authorization': 'Bearer $token'};
  }

  void _throwIfNotOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Spotify API error: ${response.statusCode} ${response.body}');
    }
  }
}
