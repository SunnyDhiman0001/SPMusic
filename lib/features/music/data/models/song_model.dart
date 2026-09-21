import '../../domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.artistId,
    required super.album,
    required super.albumId,
    required super.artworkId,
    required super.audioUrl,
    required super.duration,
    super.isFavorite,
  });
}
