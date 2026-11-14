import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/app_background.dart';

bool _hasRadialGlow(Widget w) =>
    w is DecoratedBox &&
    w.decoration is BoxDecoration &&
    (w.decoration as BoxDecoration).gradient is RadialGradient;

void main() {
  testWidgets('paints the top radial glow behind the child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const AppBackground(child: SizedBox(key: ValueKey('content'))),
      ),
    );
    expect(find.byWidgetPredicate(_hasRadialGlow), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
  });
}
