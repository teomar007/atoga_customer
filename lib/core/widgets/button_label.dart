import 'package:flutter/material.dart';

/// نص زر في سطر واحد.
///
/// يُغلّف النص بـ `FittedBox(scaleDown)`: عند طول النص المترجم يتقلّص حجم
/// الخط تلقائياً بدل النزول إلى سطر ثانٍ. ولأن `FittedBox` يمنح النص قيوداً
/// غير محدودة على المحور الأفقي، لا يمكن للسطر أن ينكسر إطلاقاً.
class ButtonLabel extends StatelessWidget {
  const ButtonLabel(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
