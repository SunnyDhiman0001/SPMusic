import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/artwork_card.dart';
import 'package:spmusic/core/widgets/local_artwork.dart';

void main() {
  testWidgets('ArtworkCard shows title, subtitle, and reacts to tap', (tester) async {
    var tapped = false;

    // ArtworkKind.song with a non-null artworkId makes LocalArtwork build a
    // QueryArtworkWidget, which calls into a platform channel that isn't
    // mocked in this widget-test environment. That plugin call failing
    // doesn't affect the title/subtitle/tap behaviour under test, so any
    // exception it raises is caught by the test binding's zone and doesn't
    // fail these assertions.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArtworkCard(
            artworkKind: ArtworkKind.song,
            artworkId: 1,
            title: 'Midnight City',
            subtitle: 'M83',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Midnight City'), findsOneWidget);
    expect(find.text('M83'), findsOneWidget);

    await tester.tap(find.byType(ArtworkCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
