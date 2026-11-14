import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/app_nav_bar.dart';

const _items = [
  AppNavItem(icon: LucideIcons.house, label: 'Home'),
  AppNavItem(icon: LucideIcons.folder, label: 'Folders'),
  AppNavItem(icon: LucideIcons.heart, label: 'Favourites'),
];

Widget _host(Brightness brightness, {int selected = 0, ValueChanged<int>? onSelected}) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        bottomNavigationBar: AppNavBar(
          items: _items,
          selectedIndex: selected,
          onSelected: onSelected ?? (_) {},
        ),
      ),
    );

void main() {
  testWidgets('dark: custom glass bar shows every label', (tester) async {
    await tester.pumpWidget(_host(Brightness.dark));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Favourites'), findsOneWidget);
  });

  testWidgets('dark: tapping an item reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(_host(Brightness.dark, onSelected: (i) => tapped = i));

    await tester.tap(find.text('Folders'));

    expect(tapped, 1);
  });

  testWidgets('dark: the selected item has the active pill, others do not', (tester) async {
    await tester.pumpWidget(_host(Brightness.dark, selected: 1));

    final selectedLabel = tester.widget<Text>(find.text('Folders'));
    final idleLabel = tester.widget<Text>(find.text('Home'));
    expect(selectedLabel.style?.fontWeight, FontWeight.w700);
    expect(idleLabel.style?.fontWeight, FontWeight.w500);
  });
}
