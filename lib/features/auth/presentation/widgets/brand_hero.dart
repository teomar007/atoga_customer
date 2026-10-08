import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// ترويسة المتجر الحمراء لشاشة الدخول: تدرّج بلون العلامة + زخارف بيضاء
/// شبه شفافة (دوائر/حلقات/نقاط — بلا خطوط مظلة) + **الشعار الأبيض فقط**
/// في الوسط مع ظل خفيف يبرزه فوق الخلفية الغنية.
class BrandHero extends StatelessWidget {
  const BrandHero({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = (MediaQuery.sizeOf(context).height * 0.34).clamp(180.0, 320.0);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: <Color>[AppColors.primary, AppColors.primaryDark], begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd),
            ),
          ),
          CustomPaint(painter: _HeroDecorPainter()),
          // اللوجو بحجم متوسط متمركز داخل القسم الملون.
          Center(child: _logoWithShadow()),
        ],
      ),
    );
  }

  Widget _logoWithShadow() {
    const String asset = 'assets/images/atoga_logo_white.png';
    Widget fallback() => const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 56);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ظل ناعم: نسخة معتمة من الشعار منزاحة قليلاً خلفه.
        Transform.translate(
          offset: const Offset(0, 5),
          child: Opacity(
            opacity: 0.30,
            child: Image.asset(asset, height: 108, fit: BoxFit.contain, color: Colors.black, errorBuilder: (BuildContext context, Object error, StackTrace? stack) => fallback()),
          ),
        ),
        Image.asset(asset, height: 108, fit: BoxFit.contain, errorBuilder: (BuildContext context, Object error, StackTrace? stack) => fallback()),
      ],
    );
  }
}

/// زخارف الهيرو: دوائر تدفّق بيضاء + حلقتان مفتوحتان + نقاط خفيفة.
class _HeroDecorPainter extends CustomPainter {
  const _HeroDecorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // دائرة تدفّق عليا يمنى.
    final Offset topGlowCenter = Offset(size.width * 0.88, size.height * 0.10);
    canvas.drawCircle(
      topGlowCenter,
      size.width * 0.38,
      Paint()
        ..shader = const RadialGradient(colors: <Color>[Color(0x2EFFFFFF), Color(0x00FFFFFF)])
            .createShader(Rect.fromCircle(center: topGlowCenter, radius: size.width * 0.38)),
    );

    // دائرة تدفّق سفلية يسرى أخف.
    final Offset bottomGlowCenter = Offset(size.width * 0.06, size.height * 0.92);
    canvas.drawCircle(
      bottomGlowCenter,
      size.width * 0.42,
      Paint()
        ..shader = const RadialGradient(colors: <Color>[Color(0x1FFFFFFF), Color(0x00FFFFFF)])
            .createShader(Rect.fromCircle(center: bottomGlowCenter, radius: size.width * 0.42)),
    );

    // حلقات رفيعة مفتوحة.
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x2EFFFFFF);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * 0.94, size.height * 0.72), radius: size.width * 0.13), 0.5, 2.3, false, ring);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * 0.10, size.height * 0.22), radius: size.width * 0.09), 3.0, 1.9, false, ring);

    // نقاط مبعثرة.
    final Paint dot = Paint()..color = const Color(0x3DFFFFFF);
    for (final Offset point in <Offset>[
      Offset(size.width * 0.22, size.height * 0.14),
      Offset(size.width * 0.72, size.height * 0.20),
      Offset(size.width * 0.34, size.height * 0.78),
      Offset(size.width * 0.78, size.height * 0.88),
      Offset(size.width * 0.55, size.height * 0.08),
    ]) {
      canvas.drawCircle(point, 3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroDecorPainter oldDelegate) => false;
}
