import 'package:flutter/material.dart';

import '../theme/app_decor.dart';
import 'pressable.dart';

/// Circular gradient button with a soft coral glow (the Home shuffle button).
class GlowButton extends StatelessWidget {
  const GlowButton({
    required this.icon,
    required this.onPressed,
    this.size = 64,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    final button = Pressable(
      pressedScale: 0.9,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: decor.accentGradient,
          boxShadow: [BoxShadow(color: decor.glowColor, blurRadius: 20)],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Icon(icon, color: Colors.white, size: size * 0.4),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
