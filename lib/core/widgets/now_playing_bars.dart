import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_decor.dart';

/// Small animated equaliser bars. Only mount it while something is playing:
/// it runs its own repeating animation until disposed.
class NowPlayingBars extends StatefulWidget {
  const NowPlayingBars({this.size = 24, this.color, super.key});

  final double size;
  final Color? color;

  @override
  State<NowPlayingBars> createState() => _NowPlayingBarsState();
}

class _NowPlayingBarsState extends State<NowPlayingBars> with SingleTickerProviderStateMixin {
  static const _barCount = 4;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barHeight(int index) {
    final phase = (_controller.value + index / _barCount) * 2 * math.pi;
    final wave = 0.5 + 0.5 * math.sin(phase);
    return widget.size * (0.25 + 0.65 * wave);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.decor.accent;
    final barWidth = widget.size * 0.14;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _barCount; i++)
              Container(
                width: barWidth,
                height: _barHeight(i),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
