import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// شاشة البداية: خلفية حمراء + شعار يظهر تدريجياً (Fade-in).
///
/// **لا تنفّذ أي تنقّل** — التوجيه مسؤوليته [AuthGate] الذي
/// يقرر بين البداية/الدخول/التطبيق حسب حالة الجلسة.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(opacity: _fade, child: const Center(child: _Logo())),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 108, height: 108, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.shopping_basket_rounded, size: 56, color: AppColors.primary)),
        const SizedBox(height: 20),
        const Text('ATOGA MARKET', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text('market', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, letterSpacing: 4)),
      ],
    );
  }
}
