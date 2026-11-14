import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Staggered fade-and-rise for list items. Only the first few items animate
/// (the ones visible when a screen opens); anything further down is shown
/// immediately, so scrolling never replays or lags behind an animation.
class Entrance extends StatelessWidget {
  const Entrance({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  /// Items past this index are not animated.
  static const int maxAnimatedIndex = 10;

  static const Duration _step = Duration(milliseconds: 45);

  static Duration delayFor(int index) => _step * index.clamp(0, maxAnimatedIndex);

  @override
  Widget build(BuildContext context) {
    if (index > maxAnimatedIndex) return child;
    return child
        .animate(delay: delayFor(index))
        .fadeIn(duration: 320.ms, curve: Curves.easeOut)
        .slideY(begin: 0.12, end: 0, duration: 320.ms, curve: Curves.easeOutCubic);
  }
}
