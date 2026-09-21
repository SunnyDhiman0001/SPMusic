import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/library_state.dart';

class LibraryFilterChips extends StatelessWidget {
  const LibraryFilterChips({required this.selected, required this.onSelected, super.key});

  final LibraryFilter selected;
  final ValueChanged<LibraryFilter> onSelected;

  static const _labels = {
    LibraryFilter.all: 'All',
    LibraryFilter.playlists: 'Playlists',
    LibraryFilter.songs: 'Songs',
    LibraryFilter.albums: 'Albums',
    LibraryFilter.artists: 'Artists',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: LibraryFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = LibraryFilter.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(_labels[filter]!),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}
