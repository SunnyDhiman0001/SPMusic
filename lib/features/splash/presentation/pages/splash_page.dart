import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends HookWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    final scale = useMemoized(
      () => Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      ),
      [controller],
    );

    final opacity = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeIn),
      [controller],
    );

    useEffect(() {
      controller.forward();
      final navigationTimer = Timer(const Duration(milliseconds: 2200), () {
        if (context.mounted) context.go('/home');
      });
      return navigationTimer.cancel;
    }, const []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.darkBackgroundGradient,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: opacity,
            child: ScaleTransition(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset('assets/icon/logo.png', width: 96, height: 96),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    const TextSpan(
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      children: [
                        TextSpan(text: 'SP', style: TextStyle(color: AppColors.logoOrange)),
                        TextSpan(text: 'Music'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
