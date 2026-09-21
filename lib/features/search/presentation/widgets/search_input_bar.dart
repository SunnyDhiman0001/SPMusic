import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Purely presentational — the parent owns the [controller]/[focusNode]
/// lifecycle (see `_SearchView`) and rebuilds this widget whenever either
/// one changes, so this widget itself needs no local state.
class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onTextChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = focusNode.hasFocus ? theme.colorScheme.primary : Colors.transparent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.roundRadius,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onTextChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search songs, artists, albums...',
              ),
            ),
          ),
          if (hasText)
            IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
