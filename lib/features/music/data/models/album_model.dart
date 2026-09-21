import '../../domain/entities/album_entity.dart';

class AlbumModel extends AlbumEntity {
  const AlbumModel({
    required super.id,
    required super.title,
    required super.artistId,
    required super.artistName,
    required super.songIds,
  });
}
