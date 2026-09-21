import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RotatingArtwork extends HookWidget {
  const RotatingArtwork({
    required this.imageUrl,
    required this.heroTag,
    required this.isPlaying,
    this.size = 280,
    super.key,
  });

  final String imageUrl;
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
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
