/// مفتاح MapTiler لبلاطات الخريطة.
///
/// يُمرَّر وقت البناء فقط ولا يُخزَّن في الكود:
/// `--dart-define=MAPTILER_KEY=...` — عند غيابه تعود الخريطة إلى
/// خادم OSM العام كاحتياط للتطوير.
const String mapTilerKey = String.fromEnvironment('MAPTILER_KEY');
