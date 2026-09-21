import 'local_artwork.dart';

class CardDisplayItem {
  const CardDisplayItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.artworkKind,
    this.artworkId,
  });

  final String id;
  final String title;
  final String subtitle;
  final ArtworkKind artworkKind;
  final int? artworkId;
}
