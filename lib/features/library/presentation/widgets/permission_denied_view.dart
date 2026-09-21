import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({
    required this.permanentlyDenied,
    required this.onRequestPermission,
    required this.onOpenSettings,
    super.key,
  });

  final bool permanentlyDenied;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              'spmusic needs access to your music',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Grant access to your device storage so we can show the songs you already have.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: permanentlyDenied ? onOpenSettings : onRequestPermission,
              child: Text(permanentlyDenied ? 'Open Settings' : 'Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
