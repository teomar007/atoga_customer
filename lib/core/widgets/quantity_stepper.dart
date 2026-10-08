import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// أزرار الكمية (+/-) — المكوّن الوحيد المسؤول عن تغيير الكمية في
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
    this.enabled = true,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final bool compact;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 28 : 34;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: size,
            semanticLabel: 'decrease',
            onTap: enabled ? onDecrement : null,
          ),
          Container(
            constraints: BoxConstraints(minWidth: compact ? 22 : 30),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 13 : 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: size,
            semanticLabel: 'increase',
            onTap: enabled ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.55,
            color: onTap == null ? AppColors.textDisabled : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
