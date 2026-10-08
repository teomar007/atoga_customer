import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'shimmer_loading.dart';

/// صورة منتج مع ذاكرة تخزين مؤقتة وحالة بديلة عند الفشل أو غياب الرابط.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final String? src = (url == null || url!.trim().isEmpty) ? null : url;
    if (src == null) {
      return _fallback();
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (BuildContext context, String url) => ShimmerLoading.box(
          borderRadius: borderRadius,
        ),
        errorWidget: (
          BuildContext context,
          String url,
          Object error,
        ) {
          return _fallback();
        },
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textDisabled,
        size: 32,
      ),
    );
  }
}
