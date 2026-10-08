import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/nominatim_geocoder.dart';
import '../domain/reverse_geocode_result.dart';

/// نتيجة محاولة تحديد الموقع: نجاح، رفض، رفض دائم، أو غير متاح.
enum LocationOutcome { granted, denied, deniedForever, serviceDisabled, unavailable }

/// منطق إذن الموقع وفق سياسات Google Play:
/// **لا يُطلب الإذن أبداً عند فتح التطبيق** — فقط عند ضغط المستخدم على
/// "تحديد موقعي الحالي" داخل شاشة العنوان، وبعد عرض نافذة تشرح السبب.
abstract final class LocationService {
  const LocationService._();

  static Future<LocationOutcome> ensurePermission({required BuildContext context}) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool accepted = await _askWithExplanation(context, l10n);
    if (accepted) {
      return LocationOutcome.granted;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationOutcome.serviceDisabled;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationOutcome.deniedForever;
    }
    return permission == LocationPermission.denied ? LocationOutcome.denied : LocationOutcome.granted;
  }

  /// نافذة سبقية إلزامية قبل طلب النظام (شرط Google Play).
  static Future<bool> _askWithExplanation(BuildContext context, AppLocalizations l10n) async {
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(Icons.location_on_rounded, color: Colors.red),
        title: Text(l10n.locationPermissionTitle),
        content: Text(l10n.locationPermissionBody),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.proceed))],
      ),
    );
    return accepted ?? false;
  }

  /// يقرأ الموقع الحالي ثم يحوّله إلى عنوان (Reverse Geocoding) بلغة التطبيق.
  static Future<({double lat, double lng, ReverseGeocodeResult? place})?> currentPlace({String languageCode = 'ar'}) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)));
      final ReverseGeocodeResult? place = await NominatimGeocoder.reverse(lat: position.latitude, lng: position.longitude, languageCode: languageCode);
      return (lat: position.latitude, lng: position.longitude, place: place);
    } on Object {
      return null;
    }
  }

  /// يعرض رسالة مناسبة حسب نتيجة الإذن.
  static void showOutcome(BuildContext context, LocationOutcome outcome) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String message = switch (outcome) { LocationOutcome.denied => l10n.locationPermissionDenied, LocationOutcome.deniedForever => l10n.locationPermissionDeniedForever, LocationOutcome.serviceDisabled || LocationOutcome.unavailable => l10n.locationUnavailable, LocationOutcome.granted => '' };
    if (message.isEmpty) {
      return;
    }
    final bool permanent = outcome == LocationOutcome.deniedForever;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), action: permanent ? SnackBarAction(label: l10n.openSettings, textColor: Colors.amber, onPressed: Geolocator.openAppSettings) : null));
  }
}
