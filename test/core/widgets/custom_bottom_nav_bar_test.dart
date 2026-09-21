import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/custom_bottom_nav_bar.dart';

void main() {
  const items = [
    NavTabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    NavTabItem(icon: Icons.search, activeIcon: Icons.search, label: 'Search'),
    NavTabItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music, label: 'Library'),
  ];

  testWidgets('CustomBottomNavBar reports tapped index', (tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 0,
            items: items,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(tappedIndex, 1);
  });

  testWidgets('CustomBottomNavBar does not fire onTap for already-selected tab', (tester) async {
    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 0,
            items: items,
            onTap: (_) => callCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(callCount, 0);
  });
}
