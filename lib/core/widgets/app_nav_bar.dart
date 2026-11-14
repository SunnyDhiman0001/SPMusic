import 'package:flutter/material.dart';

import '../theme/app_decor.dart';
import '../theme/app_radius.dart';
import 'pressable.dart';

class AppNavItem {
  const AppNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Bottom navigation: obsidian bar, active item in a dark pill with a coral
/// border and glow.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    return Material(
      color: decor.navBackground,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _GlassNavItem(
                    item: items[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({required this.item, required this.selected, required this.onTap});

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decor = context.decor;
    final color = selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        pressedScale: 0.92,
        child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? decor.navPillFill : Colors.transparent,
                borderRadius: AppRadius.roundRadius,
                border: Border.all(color: selected ? decor.navPillBorder : Colors.transparent),
                boxShadow: selected ? [BoxShadow(color: decor.navPillGlow, blurRadius: 16)] : const [],
              ),
              child: AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(item.icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
