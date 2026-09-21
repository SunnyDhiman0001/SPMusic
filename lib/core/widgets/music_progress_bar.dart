import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class MusicProgressBar extends StatefulWidget {
  const MusicProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<MusicProgressBar> createState() => _MusicProgressBarState();
}

class _MusicProgressBarState extends State<MusicProgressBar> {
  double? _dragValue;

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds.clamp(1, double.maxFinite.toInt());
    final currentMs =
        _dragValue ?? widget.position.inMilliseconds.toDouble().clamp(0, totalMs.toDouble());
    final progress = totalMs == 0 ? 0.0 : currentMs / totalMs;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: AppColors.duskBlue,
            inactiveTrackColor: AppColors.lavenderGrey.withValues(alpha: 0.25),
            thumbColor: AppColors.alabasterGrey,
            overlayColor: AppColors.duskBlue.withValues(alpha: 0.2),
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() => _dragValue = value * totalMs);
            },
            onChangeEnd: (value) {
              final seekMs = (value * totalMs).round();
              widget.onSeek(Duration(milliseconds: seekMs));
              setState(() => _dragValue = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(Duration(milliseconds: currentMs.round())),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(_format(widget.duration), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
