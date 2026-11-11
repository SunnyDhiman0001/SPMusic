import 'package:equatable/equatable.dart';

/// A real storage folder that contains at least one audio file.
class FolderEntity extends Equatable {
  const FolderEntity({
    required this.path,
    required this.songCount,
    required this.isExcluded,
    required this.isSuggestedExclusion,
  });

  /// Directory of the audio files, as reported by MediaStore.
  final String path;
  final int songCount;

  /// Hidden from the music library (All Songs, search, favourites).
  final bool isExcluded;

  /// Looks like messaging / voice-recording media rather than music.
  final bool isSuggestedExclusion;

  String get name {
    final segments = path.split('/').where((s) => s.isNotEmpty);
    return segments.isEmpty ? 'Storage' : segments.last;
  }

  /// Path with the common storage root removed, e.g. `Download/Podcasts`.
  String get displayPath {
    final trimmed = path.replaceFirst(RegExp(r'^/storage/(emulated/\d+|[^/]+)/?'), '');
    return trimmed.isEmpty ? path : trimmed;
  }

  @override
  List<Object?> get props => [path, songCount, isExcluded, isSuggestedExclusion];
}
