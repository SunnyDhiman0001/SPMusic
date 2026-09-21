import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class SearchInputBar extends StatefulWidget {
  const SearchInputBar({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  State<SearchInputBar> createState() => SearchInputBarState();
}

class SearchInputBarState extends State<SearchInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => widget.onChanged(value));
    setState(() {});
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  /// Sets the visible text without re-triggering the debounce timer, and
  /// immediately notifies [onChanged]. Used when a recent search is tapped.
  void setTextAndSearch(String value) {
    _debounce?.cancel();
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    widget.onChanged(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : Colors.transparent;
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
          Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onTextChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search songs, artists, albums...',
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clear,
            ),
        ],
      ),
    );
  }
}
