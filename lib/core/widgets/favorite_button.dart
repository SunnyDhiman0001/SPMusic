import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_decor.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.isFavorite,
    required this.onTap,
    this.size = 28,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        LucideIcons.heart,
        color: isFavorite ? context.decor.favorite : theme.colorScheme.onSurface,
        size: size,
      )
          .animate(key: ValueKey<bool>(isFavorite))
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1, 1),
            duration: 220.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
