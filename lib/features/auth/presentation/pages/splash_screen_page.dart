import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';

import '../../../../../core/widgets/image.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  final SplashScreenController _splashScreenController =
  Get.find<SplashScreenController>();

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  );

  // Logo scale animation (first)
  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  ));

  // Fade + slide for "by Gheero" (second)
  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
  ));

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
  ));

  void startAnimation() async {
    await _controller.forward();
    _splashScreenController.checkAuthStatus();
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            // 🔹 Logo Animation (centered vertically)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: assetImageWidget("logo.png"),
                );
              },
            ),

            const Spacer(),

            // 🔹 Bottom "by Gheero"
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "by",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      assetSvgImageWidget("gheero.svg", height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
