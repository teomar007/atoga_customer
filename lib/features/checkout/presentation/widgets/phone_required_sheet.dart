import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/auth_controller.dart';

/// نتيجة طلب رقم الهاتف من الـ BottomSheet.
sealed class PhoneRequest {
  const PhoneRequest();
}

/// الهاتف غير متاح — ألغى المستخدم أو واجه خطأ.
class PhoneRequestCancelled extends PhoneRequest {
  const PhoneRequestCancelled();
}

/// تم الحفظ بنجاح → يستأنف التطبيق إرسال الطلب تلقائياً.
class PhoneRequestSaved extends PhoneRequest {
  const PhoneRequestSaved(this.phone);

  final String phone;
}

/// نافذة منبثقة تطلب رقم الهاتف **قبل** إتمام الطلب.
///
/// تعيد [PhoneRequestSaved] بعد حفظ الرقم في `profiles` بنجاح، ليُكمل
/// `CheckoutScreen` إرسال الطلب دون ضغطة إضافية من المستخدم.
class PhoneRequiredSheet extends ConsumerStatefulWidget {
  const PhoneRequiredSheet({super.key, this.initialPhone});

  final String? initialPhone;

  /// يعرض النافذة ويعيد النتيجة.
  static Future<PhoneRequest?> show(BuildContext context, {String? initialPhone}) {
    return showModalBottomSheet<PhoneRequest>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: AppColors.surface, builder: (BuildContext context) => PhoneRequiredSheet(initialPhone: initialPhone));
  }

  @override
  ConsumerState<PhoneRequiredSheet> createState() => _PhoneRequiredSheetState();
}

class _PhoneRequiredSheetState extends ConsumerState<PhoneRequiredSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _phone = TextEditingController(text: widget.initialPhone ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom, left: 20, right: 20, top: 12),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.phoneRequiredTitle, style: theme.textTheme.titleMedium)),
                ],
              ),
              const SizedBox(height: 10),
              Text(l10n.phoneRequiredBody, style: theme.textTheme.bodySmall),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                autofocus: true,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
                decoration: InputDecoration(labelText: l10n.phoneNumber, hintText: l10n.phoneHint, prefixIcon: const Icon(Icons.call_rounded, size: 20), errorText: _error),
                // التحقق: غير فارغ + صيغة صحيحة.
                validator: (String? value) => _validate(value, l10n),
              ),
              const SizedBox(height: 8),
              Row(children: [Icon(Icons.lock_outline_rounded, size: 14, color: theme.textTheme.bodySmall?.color), const SizedBox(width: 6), Expanded(child: Text(l10n.phonePrivacyNote, style: theme.textTheme.bodySmall))]),
              const SizedBox(height: 18),
              FilledButton(onPressed: _saving ? null : _confirm, child: Text(_saving ? l10n.saving : l10n.confirm)),
              const SizedBox(height: 8),
              TextButton(onPressed: _saving ? null : () => Navigator.pop(context, const PhoneRequestCancelled()), child: Text(l10n.cancel)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String? _validate(String? value, AppLocalizations l10n) {
    if (Validators.isNotBlank(value)) {
      return Validators.phone(value) == null ? null : l10n.phoneInvalidShort;
    }
    return l10n.phoneRequired;
  }

  Future<void> _confirm() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final String phone = _phone.text.trim();
    // 1) حفظ الرقم في جدول `profiles` أولاً.
    final bool saved = await ref.read(authControllerProvider.notifier).savePhone(phone);
    if (!mounted) {
      return;
    }
    if (!saved) {
      setState(() {
        _saving = false;
        _error = AppLocalizations.of(context).phoneSaveFailed;
      });
      return;
    }
    // 2) إغلاق النافذة بالنجاح → CheckoutScreen يستأنف إرسال الطلب تلقائياً.
    Navigator.pop(context, PhoneRequestSaved(phone));
  }
}
