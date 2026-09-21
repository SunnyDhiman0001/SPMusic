import 'package:flutter/material.dart';

class AnimatedPlayButton extends StatelessWidget {
  const AnimatedPlayButton({
    required this.isPlaying,
    required this.onPressed,
    this.size = 56,
    this.iconSize = 28,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            key: ValueKey<bool>(isPlaying),
            color: theme.colorScheme.onPrimary,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
