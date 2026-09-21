import 'package:equatable/equatable.dart';

class ArtistEntity extends Equatable {
  const ArtistEntity({
    required this.id,
    required this.name,
    required this.trackCount,
  });

  final String id;
  final String name;
  final int trackCount;

  @override
  List<Object?> get props => [id, name, trackCount];
}
