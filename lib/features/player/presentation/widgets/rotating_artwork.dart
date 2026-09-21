import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/widgets/local_artwork.dart';

class RotatingArtwork extends HookWidget {
  const RotatingArtwork({
    required this.artworkId,
    required this.heroTag,
    required this.isPlaying,
    this.size = 280,
    super.key,
  });

  final int artworkId;
  final String heroTag;
  final bool isPlaying;
  final double size;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: const Duration(seconds: 12));

    useEffect(() {
      if (isPlaying) {
        controller.repeat();
      } else {
        controller.stop();
      }
      return null;
    }, [isPlaying]);

    return Hero(
      tag: heroTag,
      child: RotationTransition(
        turns: controller,
        child: ClipOval(
          child: LocalArtwork(
            kind: ArtworkKind.song,
            id: artworkId,
            size: size,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      ),
    );
  }
}
