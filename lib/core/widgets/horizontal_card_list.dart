import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'artwork_card.dart';
import 'card_display_item.dart';

class HorizontalCardList extends StatelessWidget {
  const HorizontalCardList({
    required this.items,
    this.isCircle = false,
    this.cardWidth = 150,
    this.onItemTap,
    super.key,
  });

  final List<CardDisplayItem> items;
  final bool isCircle;
  final double cardWidth;
  final void Function(String id)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth + 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return ArtworkCard(
            imageUrl: item.imageUrl,
            title: item.title,
            subtitle: item.subtitle,
            width: cardWidth,
            isCircle: isCircle,
            onTap: () => onItemTap?.call(item.id),
          );
        },
      ),
    );
  }
}
