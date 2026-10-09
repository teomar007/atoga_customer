import 'package:flutter/material.dart';

/// نص بسطر واحد يتحرك أفقياً ذهاباً وإياباً عند تجاوز المساحة المتاحة
/// (Marquee) — بلا أي حزمة خارجية، ويحترم اتجاه الواجهة RTL/LTR.
///
/// إن اتّسع النص تبقى ثابتة بلا حركة (لا إزعاج بصري).
class AutoMarqueeText extends StatefulWidget {
  const AutoMarqueeText({
    super.key,
    required this.text,
    this.style,
    this.velocity = 28,
    this.gap = 36,
  });

  final String text;
  final TextStyle? style;

  /// سرعة الحركة بالبكسل/ثانية.
  final double velocity;

  /// فراغ إضافي بين بداية النص ونهايته عند الالتفاف.
  final double gap;

  @override
  State<AutoMarqueeText> createState() => _AutoMarqueeTextState();
}

class _AutoMarqueeTextState extends State<AutoMarqueeText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void didUpdateWidget(covariant AutoMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ?? DefaultTextStyle.of(context).style;
    final TextDirection direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 1,
          textDirection: direction,
        )..layout();
        final double available = constraints.maxWidth;
        final double textWidth = painter.width;

        // يتّسع بلا قصّ → نص ثابت.
        if (!available.isFinite || textWidth <= available) {
          if (_controller.isAnimating) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _controller.stop();
              }
            });
          }
          return Text(widget.text, maxLines: 1, style: style);
        }

        final double distance = textWidth - available + widget.gap;
        final Duration duration = Duration(milliseconds: (distance / widget.velocity * 1000).round());
        if (_controller.duration != duration) {
          _controller.duration = duration;
        }
        if (!_controller.isAnimating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_controller.isAnimating) {
              _controller.repeat(reverse: true);
            }
          });
        }

        final double sign = direction == TextDirection.rtl ? 1 : -1;
        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Transform.translate(offset: Offset(sign * distance * _controller.value, 0), child: child);
            },
            child: Align(
              alignment: direction == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(widget.text, maxLines: 1, softWrap: false, style: style),
            ),
          ),
        );
      },
    );
  }
}
