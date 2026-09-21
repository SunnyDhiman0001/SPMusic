import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../music/domain/entities/song_entity.dart';

class SearchSongTile extends StatelessWidget {
  const SearchSongTile({
    required this.song,
    required this.onTap,
    this.trailing,
    this.leadingBorderRadius,
    this.selected = false,
    this.selectedTileColor,
    super.key,
  });

  final SongEntity song;
  final VoidCallback onTap;
  final Widget? trailing;
  final BorderRadius? leadingBorderRadius;

  /// Highlights this row using ListTile's own selected-state painting
  /// instead of an intermediate colored Container — a Container between
  /// the tile and its Material ancestor would hide the tile's own
  /// background/ink splashes (Flutter warns about exactly this).
  final bool selected;
  final Color? selectedTileColor;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedTileColor: selectedTileColor,
      leading: LocalArtwork(
        kind: ArtworkKind.song,
        id: song.artworkId,
        size: 48,
        borderRadius: leadingBorderRadius ?? AppRadius.smRadius,
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${song.artist} · ${_formatDuration(song.duration)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
    );
  }
}
