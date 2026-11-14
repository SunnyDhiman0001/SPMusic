import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/now_playing_bars.dart';

void main() {
  testWidgets('animates: a bar changes height over time', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(body: Center(child: NowPlayingBars(size: 40))),
      ),
    );

    final firstBar = find.descendant(
      of: find.byType(NowPlayingBars),
      matching: find.byType(Container),
    ).first;
    final before = tester.getSize(firstBar).height;

    await tester.pump(const Duration(milliseconds: 250));
    final after = tester.getSize(firstBar).height;

    expect(after, isNot(equals(before)));
  });
}
