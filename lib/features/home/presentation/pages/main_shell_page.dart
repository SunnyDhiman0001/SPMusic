import 'package:flutter/material.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import 'home_page.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Expanded(child: HomePage()),
          MiniPlayer(),
        ],
      ),
    );
  }
}
