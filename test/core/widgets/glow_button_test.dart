import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/glow_button.dart';

void main() {
  testWidgets('shows its icon and calls onPressed when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: Center(
            child: GlowButton(icon: LucideIcons.shuffle, onPressed: () => taps++),
          ),
        ),
      ),
    );

    expect(find.byIcon(LucideIcons.shuffle), findsOneWidget);
    await tester.tap(find.byType(GlowButton));
    expect(taps, 1);
  });
}
