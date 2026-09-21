import 'package:equatable/equatable.dart';

class SpotifyTrackEntity extends Equatable {
  const SpotifyTrackEntity({
    required this.id,
    required this.uri,
    required this.name,
    required this.artistNames,
    required this.albumArtUrl,
  });

  final String id;
  final String uri;
  final String name;
  final String artistNames;
  final String albumArtUrl;

  @override
  List<Object?> get props => [id, uri, name, artistNames, albumArtUrl];
}
