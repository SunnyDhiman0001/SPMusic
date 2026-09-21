import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    required this.artworkUrl,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String artworkUrl;
  final String audioUrl;
  final Duration duration;
  final bool isFavorite;

  SongEntity copyWith({bool? isFavorite}) {
    return SongEntity(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      album: album,
      albumId: albumId,
      artworkUrl: artworkUrl,
      audioUrl: audioUrl,
      duration: duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        artistId,
        album,
        albumId,
        artworkUrl,
        audioUrl,
        duration,
        isFavorite,
      ];
}
