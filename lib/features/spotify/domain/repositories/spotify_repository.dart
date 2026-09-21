import '../entities/spotify_playlist_entity.dart';
import '../entities/spotify_track_entity.dart';
import '../entities/spotify_user_entity.dart';

abstract class SpotifyRepository {
  Future<bool> isConnected();
  Future<void> connect();
  Future<void> disconnect();
  Future<SpotifyUserEntity> getCurrentUser();
  Future<List<SpotifyTrackEntity>> searchTracks(String query);
  Future<SpotifyPlaylistEntity> createPlaylistFromTracks({
    required String name,
    required String description,
    required List<String> trackUris,
  });
}
