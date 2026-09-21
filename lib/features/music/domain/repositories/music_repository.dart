import '../entities/album_entity.dart';
import '../entities/artist_entity.dart';
import '../entities/playlist_entity.dart';
import '../entities/song_entity.dart';

abstract class MusicRepository {
  Future<List<SongEntity>> getRecentlyPlayed();
  Future<List<PlaylistEntity>> getMadeForYouPlaylists();
  Future<List<SongEntity>> getTrendingSongs();
  Future<List<ArtistEntity>> getPopularArtists();
  Future<List<SongEntity>> getAllSongs();
  Future<List<ArtistEntity>> getAllArtists();
  Future<List<AlbumEntity>> getAllAlbums();
  Future<List<PlaylistEntity>> getAllPlaylists();
  Future<PlaylistEntity> getPlaylistById(String id);
  Future<List<SongEntity>> getSongsByIds(List<String> ids);
  Future<List<SongEntity>> searchSongs(String query);
  Future<List<ArtistEntity>> searchArtists(String query);
  Future<List<AlbumEntity>> searchAlbums(String query);
  Future<List<PlaylistEntity>> searchPlaylists(String query);
  Future<List<SongEntity>> getFavoriteSongs();
  Future<void> toggleFavorite(String songId);
  Future<void> recordPlayed(String songId);
  Future<void> refresh();
}
