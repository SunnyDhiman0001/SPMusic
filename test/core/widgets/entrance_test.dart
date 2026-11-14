import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/entrance.dart';

Widget _host(int index) => MaterialApp(
      home: Entrance(index: index, child: const Text('row')),
    );

void main() {
  testWidgets('early items fade in and finish fully visible', (tester) async {
    await tester.pumpWidget(_host(0));
    expect(find.byType(Animate), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('row'), findsOneWidget);
    final fade = tester.widget<FadeTransition>(find.descendant(
      of: find.byType(Entrance),
      matching: find.byType(FadeTransition),
    ).first);
    expect(fade.opacity.value, 1);
  });

  testWidgets('later items are shown immediately with no animation', (tester) async {
    await tester.pumpWidget(_host(Entrance.maxAnimatedIndex + 1));

    expect(find.byType(Animate), findsNothing);
    expect(find.text('row'), findsOneWidget);
  });

  testWidgets('stagger delay grows with the index but is capped', (tester) async {
    expect(Entrance.delayFor(0), Duration.zero);
    expect(Entrance.delayFor(2), greaterThan(Entrance.delayFor(1)));
    expect(Entrance.delayFor(Entrance.maxAnimatedIndex), Entrance.delayFor(Entrance.maxAnimatedIndex));
    expect(Entrance.delayFor(Entrance.maxAnimatedIndex), lessThan(const Duration(seconds: 1)));
  });
}
