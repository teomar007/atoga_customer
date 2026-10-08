import 'package:flutter_riverpod/flutter_riverpod.dart';

/// فهرس التبويب النشط في الهيكل الرئيسي:
/// 0 = الرئيسية، 1 = السلة، 2 = المحفظة، 3 = طلباتي، 4 = الكوبونات، 5 = حسابي.
///
/// جعله مزوّداً يتيح لأي شاشة (مثل السلة الفارغة) توجيه المستخدم إلى
/// تبويب الرئيسية مباشرةً بدل `Navigator.pop` الذي لا ينفع داخل تبويبات.
final mainTabIndexProvider = NotifierProvider<MainTabIndexController, int>(MainTabIndexController.new);

class MainTabIndexController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (index < 0 || index > 5) {
      return;
    }
    state = index;
  }
}
