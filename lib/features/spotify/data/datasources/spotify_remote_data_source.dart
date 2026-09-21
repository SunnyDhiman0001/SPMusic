abstract class SpotifyRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentUser();
  Future<List<Map<String, dynamic>>> searchTracks(String query, {int limit = 10});
  Future<Map<String, dynamic>> createPlaylist(String name, String description);
  Future<void> addTracksToPlaylist(String playlistId, List<String> uris);
}
