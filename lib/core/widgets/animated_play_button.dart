import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_decor.dart';

class AnimatedPlayButton extends StatelessWidget {
  const AnimatedPlayButton({
    required this.isPlaying,
    required this.onPressed,
    this.size = 56,
    this.iconSize = 28,
    this.color,
    this.iconColor,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  /// Solid fill override (the mini-player uses a white button). When null:
  /// the accent gradient with a soft glow.
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decor = context.decor;
    final useGradient = color == null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          gradient: useGradient ? decor.accentGradient : null,
          boxShadow: useGradient ? [BoxShadow(color: decor.glowColor, blurRadius: 16)] : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            isPlaying ? LucideIcons.pause : LucideIcons.play,
            key: ValueKey<bool>(isPlaying),
            color: iconColor ?? theme.colorScheme.onPrimary,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
