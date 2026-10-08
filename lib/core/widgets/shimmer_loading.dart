import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// هياكل تحميل بتأثير الوميض (بديل الدائرة الدوارة).
abstract final class ShimmerLoading {
  const ShimmerLoading._();

  static Widget box({
    double? width,
    double? height,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) {
    return _ShimmerHost(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  /// هيكل بطاقة منتج (يطابق تصميم البطاقة الحقيقية لتقليل القفز البصري).
  static Widget productCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: box(borderRadius: BorderRadius.circular(14)),
        ),
        const SizedBox(height: 8),
        box(height: 12, borderRadius: BorderRadius.circular(6)),
        const SizedBox(height: 6),
        box(
          height: 12,
          width: 70,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        box(height: 32, borderRadius: BorderRadius.circular(10)),
      ],
    );
  }

  static Widget productGrid({int columns = 2, int count = 6}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => productCard(),
    );
  }

  static Widget listTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          box(width: 56, height: 56, borderRadius: BorderRadius.circular(12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(height: 12, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                box(
                  height: 12,
                  width: 90,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          box(width: 28, height: 28, borderRadius: BorderRadius.circular(8)),
        ],
      ),
    );
  }
}

/// يغلّف الهيكل بوميض متكرر واحد.
class _ShimmerHost extends StatelessWidget {
  const _ShimmerHost({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.divider,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}
