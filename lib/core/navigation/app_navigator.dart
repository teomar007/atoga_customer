import 'package:flutter/material.dart';

/// مفتاح Navigator العام: يتيح فتح شاشة (مثل تتبّع الطلب) من مستمعي
/// الإشعارات خارج شجرة الواجهات.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
