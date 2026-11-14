import 'package:flutter/material.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/local_artwork.dart';
import '../../../../core/widgets/now_playing_bars.dart';
import '../../../music/domain/entities/song_entity.dart';

class SearchSongTile extends StatelessWidget {
  const SearchSongTile({
    required this.song,
    required this.onTap,
    this.trailing,
    this.leadingBorderRadius,
    this.selected = false,
    this.selectedTileColor,
    this.isCurrent = false,
    this.isPlaying = false,
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

  /// This row is the song the player is on: it gets a bordered glass
  /// highlight.
  final bool isCurrent;

  /// The current song is audibly playing: animated bars overlay the artwork
  /// (the real cover stays underneath).
  final bool isPlaying;

  static const double _artworkSize = 48;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _leading(BorderRadius radius) {
    final artwork = LocalArtwork(
      kind: ArtworkKind.song,
      id: song.artworkId,
      size: _artworkSize,
      borderRadius: radius,
    );
    if (!(isCurrent && isPlaying)) return artwork;
    return Stack(
      alignment: Alignment.center,
      children: [
        artwork,
        ClipRRect(
          borderRadius: radius,
          child: const SizedBox(
            width: _artworkSize,
            height: _artworkSize,
            child: ColoredBox(color: Color(0x73000000)),
          ),
        ),
        const NowPlayingBars(size: 26),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    final theme = Theme.of(context);

    // Every row gets the same inset and (transparent) border shape, so the
    // current row's glass highlight lines up with the others.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: selectedTileColor,
        selectedColor: theme.colorScheme.onSurface,
        tileColor: isCurrent ? decor.glassSurface : null,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgRadius,
          side: BorderSide(color: isCurrent ? decor.glassBorder : Colors.transparent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: _leading(leadingBorderRadius ?? AppRadius.smRadius),
        title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${song.artist} · ${_formatDuration(song.duration)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
      ),
    );
  }
}
