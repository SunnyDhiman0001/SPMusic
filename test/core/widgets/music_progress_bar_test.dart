import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/music_progress_bar.dart';

void main() {
  testWidgets('MusicProgressBar calls onSeek with proportional duration on drag end', (
    tester,
  ) async {
    Duration? captured;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MusicProgressBar(
            position: Duration.zero,
            duration: const Duration(seconds: 100),
            onSeek: (d) => captured = d,
          ),
        ),
      ),
    );

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChangeEnd!(0.5);

    expect(captured, const Duration(seconds: 50));
  });

  testWidgets('MusicProgressBar shows formatted position and duration text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MusicProgressBar(
            position: const Duration(seconds: 65),
            duration: const Duration(seconds: 130),
            onSeek: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('1:05'), findsOneWidget);
    expect(find.text('2:10'), findsOneWidget);
  });
}
