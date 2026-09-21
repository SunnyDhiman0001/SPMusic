import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('dark theme uses dark brightness and Material 3', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
    });

    test('light theme uses light brightness and Material 3', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
    });
  });
}
