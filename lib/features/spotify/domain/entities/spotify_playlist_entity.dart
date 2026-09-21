import 'package:equatable/equatable.dart';

class SpotifyPlaylistEntity extends Equatable {
  const SpotifyPlaylistEntity({
    required this.id,
    required this.name,
    required this.embedUrl,
  });

  final String id;
  final String name;
  final String embedUrl;

  @override
  List<Object?> get props => [id, name, embedUrl];
}
