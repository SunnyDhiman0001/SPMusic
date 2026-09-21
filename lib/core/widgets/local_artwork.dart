import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

enum ArtworkKind { song, album, none }

class LocalArtwork extends StatelessWidget {
  const LocalArtwork({
    required this.kind,
    this.id,
    this.size = 48,
    this.borderRadius,
    super.key,
  });

  final ArtworkKind kind;
  final int? id;
  final double size;
  final BorderRadius? borderRadius;

  IconData get _fallbackIcon => switch (kind) {
        ArtworkKind.song => Icons.music_note,
        ArtworkKind.album => Icons.album,
        ArtworkKind.none => Icons.queue_music,
      };

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    final placeholder = ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).cardColor,
        child: Icon(_fallbackIcon, size: size * 0.4),
      ),
    );

    if (kind == ArtworkKind.none || id == null) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: QueryArtworkWidget(
        id: id!,
        type: kind == ArtworkKind.album ? ArtworkType.ALBUM : ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.zero,
        keepOldArtwork: true,
        nullArtworkWidget: SizedBox(
          width: size,
          height: size,
          child: Icon(_fallbackIcon, size: size * 0.4),
        ),
      ),
    );
  }
}
