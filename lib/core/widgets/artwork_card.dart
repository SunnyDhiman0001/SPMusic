import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'local_artwork.dart';

class ArtworkCard extends StatefulWidget {
  const ArtworkCard({
    required this.artworkKind,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.artworkId,
    this.width = 150,
    this.isCircle = false,
    super.key,
  });

  final ArtworkKind artworkKind;
  final int? artworkId;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double width;
  final bool isCircle;

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  double _scale = 1;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.isCircle ? AppRadius.roundRadius : AppRadius.mdRadius;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalArtwork(
                kind: widget.artworkKind,
                id: widget.artworkId,
                size: widget.width,
                borderRadius: radius,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
