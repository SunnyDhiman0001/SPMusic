import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    required this.artworkId,
    required this.audioUrl,
    required this.duration,
    this.folderPath = '',
    this.fileSize = 0,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final int artworkId;
  final String audioUrl;
  final Duration duration;

  /// Directory containing the audio file ('' when unknown, e.g. remote URLs).
  final String folderPath;
  final int fileSize;
  final bool isFavorite;

  SongEntity copyWith({bool? isFavorite}) {
    return SongEntity(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      album: album,
      albumId: albumId,
      artworkId: artworkId,
      audioUrl: audioUrl,
      duration: duration,
      folderPath: folderPath,
      fileSize: fileSize,
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
        artworkId,
        audioUrl,
        duration,
        folderPath,
        fileSize,
        isFavorite,
      ];
}
