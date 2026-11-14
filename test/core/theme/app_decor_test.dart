import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/theme/app_colors.dart';
import 'package:spmusic/core/theme/app_decor.dart';

Future<AppDecor> _decorFor(WidgetTester tester, ThemeData theme) async {
  late AppDecor decor;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          decor = context.decor;
          return const SizedBox();
        },
      ),
    ),
  );
  return decor;
}

void main() {
  test('dark decor is the glass orange/black look', () {
    const d = AppDecor.dark;
    expect(d.accent, const Color(0xFFFF6B4A));
    expect(d.glassSurface, const Color(0xBF181A20));
    expect(d.glassBorder, const Color(0x1FFFFFFF));
    expect(d.blurSigma, 12);
    expect(d.ambientGlow, const Color(0x38FF6B4A));
    expect(d.navBackground, AppColors.obsidian);
    expect(d.navPillFill, const Color(0xFF1E2028));
    expect(d.progressActive, AppColors.coral);
    expect(d.accentGradient.colors, [const Color(0xFFFF8F6B), const Color(0xFFFF5733)]);
  });

  group('context.decor', () {
    testWidgets('falls back to the dark decor when the theme has no extension', (tester) async {
      final decor = await _decorFor(tester, ThemeData(brightness: Brightness.dark));
      expect(identical(decor, AppDecor.dark), isTrue);
    });

    testWidgets('uses the registered extension when present', (tester) async {
      final custom = AppDecor.dark.copyWith(blurSigma: 3);
      final decor = await _decorFor(
        tester,
        ThemeData(brightness: Brightness.dark, extensions: [custom]),
      );
      expect(decor.blurSigma, 3);
    });
  });
}
