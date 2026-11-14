import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_decor.dart';
import '../theme/app_radius.dart';

/// Frosted card: translucent fill with a hairline border.
///
/// [blur] adds a backdrop blur and should only be used where content
/// scrolls behind the card (the mini-player); list rows stay un-blurred for
/// scroll performance. [elevated] adds the soft drop shadow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.blur = false,
    this.elevated = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final bool blur;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    final borderRadius = radius ?? AppRadius.lgRadius;

    // Material(transparency) keeps ListTile/InkWell splashes visible on top
    // of the card's fill instead of underneath it.
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: decor.glassSurface,
        borderRadius: borderRadius,
        border: Border.all(color: decor.glassBorder),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );

    if (blur) {
      card = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: decor.blurSigma, sigmaY: decor.blurSigma),
          child: card,
        ),
      );
    }

    // The shadow sits outside the blur clip so it is not cut off.
    if (elevated) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: card,
      );
    }

    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}
