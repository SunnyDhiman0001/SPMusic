import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/artwork_card.dart';

void main() {
  testWidgets('ArtworkCard shows title, subtitle, and reacts to tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArtworkCard(
            imageUrl: 'https://example.com/art.jpg',
            title: 'Midnight City',
            subtitle: 'M83',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Midnight City'), findsOneWidget);
    expect(find.text('M83'), findsOneWidget);

    await tester.tap(find.byType(ArtworkCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
