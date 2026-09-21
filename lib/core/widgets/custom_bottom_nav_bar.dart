import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class NavTabItem {
  const NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final List<NavTabItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++) _buildTab(context, i),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final theme = Theme.of(context);
    final selected = index == selectedIndex;
    final item = items[index];
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () {
        if (!selected) {
          HapticFeedback.selectionClick();
          onTap(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: AppRadius.roundRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              scale: selected ? 1.1 : 1.0,
              child: Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: theme.textTheme.labelSmall!.copyWith(color: color),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
