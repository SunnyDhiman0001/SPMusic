import '../../domain/entities/playlist_entity.dart';

class PlaylistModel extends PlaylistEntity {
  const PlaylistModel({
    required super.id,
    required super.name,
    required super.description,
    required super.songIds,
    required super.creator,
  });
}
