import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/app_colors.dart';

class PlayerBottomActions extends StatelessWidget {
  const PlayerBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: null,
          icon: const Icon(LucideIcons.list_music, color: AppColors.textSecondaryDark),
          label: const Text('Queue', style: TextStyle(color: AppColors.textSecondaryDark)),
        ),
        TextButton.icon(
          onPressed: null,
          icon: const Icon(LucideIcons.captions, color: AppColors.textSecondaryDark),
          label: const Text('Lyrics', style: TextStyle(color: AppColors.textSecondaryDark)),
        ),
      ],
    );
  }
}
