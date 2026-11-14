import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/glass_card.dart';

Widget _host(Brightness brightness, Widget card) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: Center(child: card)),
    );

void main() {
  testWidgets('dark + blur: wraps the card in a BackdropFilter', (tester) async {
    await tester.pumpWidget(_host(Brightness.dark, const GlassCard(blur: true, child: Text('hi'))));
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('dark without blur: no BackdropFilter', (tester) async {
    await tester.pumpWidget(_host(Brightness.dark, const GlassCard(child: Text('hi'))));
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
