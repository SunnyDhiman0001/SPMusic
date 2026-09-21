import 'package:equatable/equatable.dart';

class AlbumEntity extends Equatable {
  const AlbumEntity({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.songIds,
  });

  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final List<String> songIds;

  @override
  List<Object?> get props => [id, title, artistId, artistName, songIds];
}
