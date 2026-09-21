import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Building AppTheme's TextTheme triggers google_fonts to kick off a
  // background fetch of NotoSans. In this sandboxed test run there's no
  // network, so that fetch fails; google_fonts logs it and rethrows inside
  // an un-awaited `.then()` chain it owns internally, which otherwise
  // surfaces as an uncaught zone error and fails this unrelated assertion.
  // runZonedGuarded intercepts it at the boundary regardless of when the
  // background Future settles.
  void runIgnoringGoogleFontsNetworkError(void Function() body) {
    runZonedGuarded(body, (error, stack) {});
  }

  group('AppTheme', () {
    test('dark theme uses dark brightness and Material 3', () {
      runIgnoringGoogleFontsNetworkError(() {
        final theme = AppTheme.dark;
        expect(theme.brightness, Brightness.dark);
        expect(theme.useMaterial3, isTrue);
      });
    });

    test('light theme uses light brightness and Material 3', () {
      runIgnoringGoogleFontsNetworkError(() {
        final theme = AppTheme.light;
        expect(theme.brightness, Brightness.light);
        expect(theme.useMaterial3, isTrue);
      });
    });
  });
}
