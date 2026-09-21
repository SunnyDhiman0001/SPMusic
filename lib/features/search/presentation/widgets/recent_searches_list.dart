import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class RecentSearchesList extends StatelessWidget {
  const RecentSearchesList({
    required this.searches,
    required this.onTapSearch,
    required this.onClear,
    super.key,
  });

  final List<String> searches;
  final ValueChanged<String> onTapSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: Text('Search for songs, artists, albums, or playlists')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ),
        for (final query in searches)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () => onTapSearch(query),
          ),
      ],
    );
  }
}
