import 'package:equatable/equatable.dart';

class PlaylistEntity extends Equatable {
  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.songIds,
    required this.creator,
  });

  final String id;
  final String name;
  final String description;
  final List<String> songIds;
  final String creator;

  @override
  List<Object?> get props => [id, name, description, songIds, creator];
}
