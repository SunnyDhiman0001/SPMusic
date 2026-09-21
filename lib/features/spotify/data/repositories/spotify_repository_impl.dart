import '../../domain/entities/spotify_playlist_entity.dart';
import '../../domain/entities/spotify_track_entity.dart';
import '../../domain/entities/spotify_user_entity.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../datasources/spotify_remote_data_source.dart';
import '../services/spotify_auth_service.dart';

class SpotifyRepositoryImpl implements SpotifyRepository {
  SpotifyRepositoryImpl(this._authService, this._remote);

  final SpotifyAuthService _authService;
  final SpotifyRemoteDataSource _remote;

  @override
  Future<bool> isConnected() => _authService.hasValidSession();

  @override
  Future<void> connect() => _authService.login();

  @override
  Future<void> disconnect() => _authService.logout();

  @override
  Future<SpotifyUserEntity> getCurrentUser() async {
    final json = await _remote.getCurrentUser();
    return SpotifyUserEntity(
      id: json['id'] as String,
      displayName: (json['display_name'] as String?) ?? 'Spotify User',
      email: (json['email'] as String?) ?? '',
    );
  }

  @override
  Future<List<SpotifyTrackEntity>> searchTracks(String query) async {
    final raw = await _remote.searchTracks(query);
    return raw.map(_mapTrack).toList();
  }

  @override
  Future<SpotifyPlaylistEntity> createPlaylistFromTracks({
    required String name,
    required String description,
    required List<String> trackUris,
  }) async {
    final playlist = await _remote.createPlaylist(name, description);
    final id = playlist['id'] as String;
    await _remote.addTracksToPlaylist(id, trackUris);
    return SpotifyPlaylistEntity(
      id: id,
      name: playlist['name'] as String,
      embedUrl: 'https://open.spotify.com/embed/playlist/$id?utm_source=generator&theme=0',
    );
  }

  SpotifyTrackEntity _mapTrack(Map<String, dynamic> json) {
    final artists = (json['artists'] as List? ?? const [])
        .map((a) => a['name'] as String)
        .join(', ');
    final images = (json['album']?['images'] as List?) ?? const [];
    final artUrl = images.isNotEmpty ? images.first['url'] as String : '';
    return SpotifyTrackEntity(
      id: json['id'] as String,
      uri: json['uri'] as String,
      name: json['name'] as String,
      artistNames: artists,
      albumArtUrl: artUrl,
    );
  }
}
