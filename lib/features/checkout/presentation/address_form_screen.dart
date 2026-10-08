import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/address_repository.dart';
import '../domain/address.dart';
import '../domain/delivery_zone.dart';
import '../domain/reverse_geocode_result.dart';
import 'checkout_controller.dart';
import 'delivery_zones_provider.dart';
import 'location_service.dart';
import 'widgets/location_picker_field.dart';

/// إضافة / تعديل عنوان توصيل (خريطة + حقول نصية + ملاحظات للمندوب).
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.existing});

  final Address? existing;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late final TextEditingController _phone;
  late String _label = widget.existing?.label ?? 'home';
  /// منطقة التوصيل — إلزامية للحفظ (لا حفظ بلا حيّ).
  String? _zoneId;
  double? _lat;
  double? _lng;
  bool _saving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _zoneId = widget.existing?.deliveryZoneId;
    _lat = widget.existing?.latitude;
    _lng = widget.existing?.longitude;
    // الهاتف الافتراضي من ملف البروفايل؛ عنوان يحمل رقماً خاصاً يُعرض رقمه.
    // التعديل هنا لا يمسّ الملف الشخصي — يُكتب داخل هذا العنوان فقط.
    final String existing = (widget.existing?.phone ?? '').trim();
    _phone = TextEditingController(text: existing.isEmpty ? (ref.read(currentUserProvider)?.phone ?? '') : existing);
  }

  @override
  void dispose() {
    _notes.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool editing = widget.existing != null;
    final AsyncValue<List<DeliveryZone>> zonesAsync = ref.watch(deliveryZonesProvider);
    final List<DeliveryZone> zones = zonesAsync.valueOrNull ?? const <DeliveryZone>[];
    final bool zonesLoading = zonesAsync.isLoading && zonesAsync.valueOrNull == null;
    final String lang = Localizations.localeOf(context).languageCode;
    // قيمة خارج القائمة (حُذف الحيّ مثلاً) تُخفى وإلا أسقطت قاعدة
    // التأكيد داخل DropdownButtonFormField.
    final String? zoneValue = zones.any((DeliveryZone zone) => zone.id == _zoneId) ? _zoneId : null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l10n.editAddress : l10n.addNewAddress, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // 1) تسمية العنوان — خيارات سريعة.
            Text(l10n.addressLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _labelChip('home', l10n.addressLabelHome, () => setState(() => _label = 'home')),
                _labelChip('work', l10n.addressLabelWork, () => setState(() => _label = 'work')),
                _labelChip('other', l10n.addressLabelOther, () => setState(() => _label = 'other')),
              ],
            ),
            const SizedBox(height: 16),
            // 2) منطقة التوصيل — الاسم بجانب سعر التوصيل، من `delivery_zones`.
            DropdownButtonFormField<String>(
              // `initialValue` بدل `value` (المهمل منذ Flutter 3.33)، و`key`
              // يعيد بناء الحقل عند وصول القائمة حتى يظهر الحيّ المحفوظ.
              key: ValueKey<String>(zoneValue ?? ''),
              initialValue: zoneValue,
              isExpanded: true,
              hint: Text(zonesLoading ? l10n.loading : (zones.isEmpty ? l10n.deliveryZonesEmpty : l10n.deliveryZone)),
              items: zones
                  .map((DeliveryZone zone) => DropdownMenuItem<String>(
                        value: zone.id,
                        child: Text(
                          '${zone.name} - ${Formatters.price(zone.deliveryFee, lang)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (zonesLoading || zones.isEmpty) ? null : (String? value) => setState(() => _zoneId = value),
              validator: (String? value) => (value == null || value.isEmpty) ? l10n.fieldRequired : null,
              decoration: InputDecoration(labelText: l10n.deliveryZone),
            ),
            const SizedBox(height: 16),
            // 3) الموقع على الخريطة — زر "استخدم موقعي الحالي" + النقر اليدوي.
            LocationPickerField(
              latitude: _lat,
              longitude: _lng,
              busy: _locating,
              onChanged: (double lat, double lng) => setState(() { _lat = lat; _lng = lng; }),
              onRequestCurrent: _useCurrentLocation,
            ),
            const SizedBox(height: 16),
            // 4) رقم الهاتف + ملاحظات التوصيل (اختياريان).
            // الهاتف إلزامي: مع اختيار الحي يكفي للحفظ (الموقع اختياري).
            TextFormField(controller: _phone, keyboardType: Validators.phoneKeyboard, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: l10n.contactPhone), validator: (String? v) => Validators.phoneRequired(v) == null ? null : l10n.phoneInvalidShort),
            const SizedBox(height: 12),
            TextFormField(controller: _notes, maxLines: 2, decoration: InputDecoration(labelText: '${l10n.notesForCourier} (${l10n.optional})', hintText: l10n.notesForCourierHint)),
            const SizedBox(height: 22),
            FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? l10n.sendingOrder : l10n.save)),
          ],
        ),
      ),
    );
  }

  Widget _labelChip(String value, String label, VoidCallback onTap) {
    final bool selected = _label == value;
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }

  /// طلب إذن الموقع هنا فقط — عند ضغط المستخدم (سياسة Google Play).
  Future<void> _useCurrentLocation() async {
    // نلتقط اللغة قبل أي await كي تعود أسماء الأماكن باللغة الحالية.
    final String lang = Localizations.localeOf(context).languageCode;
    final LocationOutcome outcome = await LocationService.ensurePermission(context: context);
    if (!mounted) {
      return;
    }
    if (outcome != LocationOutcome.granted) {
      LocationService.showOutcome(context, outcome);
      return;
    }
    setState(() => _locating = true);
    final ({double lat, double lng, ReverseGeocodeResult? place})? position = await LocationService.currentPlace(languageCode: lang);
    if (!mounted) {
      return;
    }
    if (position == null) {
      setState(() => _locating = false);
      LocationService.showOutcome(context, LocationOutcome.unavailable);
      return;
    }
    setState(() {
      _locating = false;
      _lat = position.lat;
      _lng = position.lng;
    });
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    // بوابة الحفظ: لا حفظ بلا منطقة توصيل — تغطّي الحالات التي لا يوجد
    // فيها حقل القائمة (أثناء التحميل أو لو كانت القائمة فارغة).
    if (_zoneId == null || _zoneId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fieldRequired)));
      return;
    }
    // الموقع اختياري تماماً: لا بوابة هنا. `latitude`/`longitude` تبقى
    // nullable في النموذج والقاعدة، فيُحفظ العنوان بلا دبوس خريطة.
    setState(() => _saving = true);
    try {
      final Address saved = await ref.read(addressesControllerProvider.notifier).save(Address(
        id: widget.existing?.id,
        label: _label,
        // الحقول التفصيلية أُلغيت من الواجهة: نحافظ على قيم العنوان القديم
        // عند التعديل ولا نكتب فراغاً فوق بيانات سابقة.
        street: widget.existing?.street ?? '',
        building: widget.existing?.building ?? '',
        apartment: widget.existing?.apartment ?? '',
        deliveryZoneId: _zoneId,
        notes: _notes.text.trim(),
        phone: _phone.text.trim(),
        latitude: _lat,
        longitude: _lng,
      ));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.addressSaved)));
      Navigator.of(context).pop(saved);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      // رسالة مفهومة للمستخدم؛ التفصيل التقني يُرفق فقط للأخطاء غير المتوقعة
      // (مثل AddressException(insert_failed)) حتى لا نعرض رموزاً مصدرياً.
      final String detail = error is AddressException ? '' : ' $error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.somethingWentWrong}$detail')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
