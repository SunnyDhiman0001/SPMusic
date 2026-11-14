import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/pressable.dart';

double _scale(WidgetTester tester) => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

void main() {
  testWidgets('shrinks while pressed and returns to full size on release', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: Pressable(child: SizedBox(width: 80, height: 80)))),
    );
    expect(_scale(tester), 1);

    final gesture = await tester.startGesture(tester.getCenter(find.byType(Pressable)));
    await tester.pump();
    expect(_scale(tester), lessThan(1));

    await gesture.up();
    await tester.pump();
    expect(_scale(tester), 1);
  });

  testWidgets('does not swallow taps meant for its child', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Pressable(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: const SizedBox(width: 80, height: 80),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Pressable));

    expect(taps, 1);
  });
}
