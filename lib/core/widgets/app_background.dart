import 'package:flutter/material.dart';

import '../theme/app_decor.dart';

/// Opaque page background: the obsidian base with the soft coral radial glow
/// at the top.
///
/// Wrap a route's `Scaffold` in this and give that `Scaffold`
/// `backgroundColor: Colors.transparent`. Because this widget paints its own
/// opaque base, page transitions never become see-through.
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).scaffoldBackgroundColor;
    final glow = context.decor.ambientGlow;
    return ColoredBox(
      color: base,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1),
                    radius: 0.9,
                    colors: [glow, base.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
