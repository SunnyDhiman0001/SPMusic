import 'package:equatable/equatable.dart';

class PlaylistEntity extends Equatable {
  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.songIds,
    required this.creator,
  });

  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final List<String> songIds;
  final String creator;

  @override
  List<Object?> get props => [id, name, description, coverUrl, songIds, creator];
}
