import 'package:flutter/material.dart';

import 'empty_state_view.dart';

/// حالة الخطأ / انقطاع الاتصال مع زر "حاول مجدداً".
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.title,
    this.message,
    required this.retryLabel,
    required this.onRetry,
    this.isOffline = false,
  });

  final String title;
  final String? message;
  final String retryLabel;
  final VoidCallback onRetry;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: retryLabel,
      onAction: onRetry,
    );
  }
}
