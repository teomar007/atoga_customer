import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/map_tiler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// خريطة اختيار موقع التسليم: MapTiler عند توفر المفتاح، وOSM احتياطاً.
class LocationPickerField extends StatefulWidget {
  const LocationPickerField({super.key, required this.latitude, required this.longitude, required this.onChanged, this.onRequestCurrent, this.busy = false});

  final double? latitude;
  final double? longitude;
  final void Function(double lat, double lng) onChanged;

  /// زر "استخدم موقعي الحالي" (يعرض Spinner أثناء الجلب).
  final VoidCallback? onRequestCurrent;

  final bool busy;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> with TickerProviderStateMixin {
  /// الجزائر العاصمة — نقطة مركزية افتراضية عند أول فتح.
  static const LatLng fallbackCenter = LatLng(36.7538, 3.0588);

  final MapController _map = MapController();
  bool _ready = false;

  @override
  void didUpdateWidget(covariant LocationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحريك سلس عند تغيّر الإحداثيات من مصدر خارجي (زر الموقع الحالي).
    if (_ready && widget.latitude != null && widget.longitude != null) {
      _moveTo(LatLng(widget.latitude!, widget.longitude!), zoom: 17);
    }
  }

  /// تحريك سلس (FlyTo) لتمرير الخريطة نحو الإحداثيات.
  void _moveTo(LatLng target, {double? zoom}) {
    final double z = zoom ?? _map.camera.zoom;
    _map.move(target, z);
  }

  LatLng get _current {
    if (widget.latitude == null || widget.longitude == null) {
      return fallbackCenter;
    }
    return LatLng(widget.latitude!, widget.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.pinLocation, style: theme.textTheme.titleSmall)),
            if (widget.onRequestCurrent != null)
              _LocateButton(onTap: widget.onRequestCurrent!, busy: widget.busy, label: l10n.useCurrentLocation, locating: l10n.locating),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 240,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _current,
                    initialZoom: widget.latitude == null ? 12 : 17,
                    minZoom: 4,
                    maxZoom: 19,
                    onMapReady: () => setState(() => _ready = true),
                    onTap: (TapPosition position, LatLng point) => widget.onChanged(point.latitude, point.longitude),
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                  ),
                  children: <Widget>[
                    TileLayer(urlTemplate: _tileTemplate(), userAgentPackageName: 'com.atogamarket.atoga_customer', maxZoom: 19),
                    RichAttributionWidget(attributions: <SourceAttribution>[
                      TextSourceAttribution('MapTiler © OpenStreetMap contributors', onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright'))),
                    ]),
                  ],
                ),
                // الدبوس ثابت في منتصف الشاشة (Center Marker).
                const IgnorePointer(child: Center(child: _CenterPin())),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(widget.latitude == null ? l10n.pinLocationHint : 'Lat: ${widget.latitude!.toStringAsFixed(5)}  •  Lng: ${widget.longitude!.toStringAsFixed(5)}', style: theme.textTheme.bodySmall),
      ],
    );
  }

  /// بلاطات MapTiler عند توفر المفتاح، وإلا خادم OSM العام (تطوير).
  static String _tileTemplate() {
    if (mapTilerKey.isNotEmpty) {
      return 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }
}

/// زر تحديد الموقع: يتحوّل إلى Spinner أثناء جلب الإحداثيات.
class _LocateButton extends StatelessWidget {
  const _LocateButton({required this.onTap, required this.busy, required this.label, required this.locating});

  final VoidCallback onTap;
  final bool busy;
  final String label;
  final String locating;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: busy ? null : onTap,
      icon: busy
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          : const Icon(Icons.my_location_rounded, size: 18),
      label: Text(busy ? locating : label, style: const TextStyle(fontSize: 12.5)),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const <BoxShadow>[BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))])),
        Container(width: 2, height: 10, color: AppColors.primary),
      ],
    );
  }
}
