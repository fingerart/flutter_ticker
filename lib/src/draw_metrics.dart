import 'dart:collection';

import 'package:flutter/material.dart';

import 'character_set.dart';

class CharMetrics {
  CharMetrics(this._characters, this._style);

  final metrics = <int, Metrics>{};
  final _tps = Queue<TextPainter>();

  TickerCharacters _characters;

  set characters(TickerCharacters value) {
    if (value == _characters) return;
    _recycleTextPainter();
    _characters = value;
  }

  /// Character style
  TextStyle? _style;

  set style(TextStyle? value) {
    if (value == _style) return;
    _recycleTextPainter();
    _style = value;
  }

  /// Get character metrics
  Metrics getCharMetrics(String char) {
    return metrics.putIfAbsent(Object.hash(char, _style), () {
      return Metrics(_obtainTextPainter(char));
    });
  }

  /// get [src] and [dst] indexes
  ({int begin, int end})? getCharIndexes(String src, String dst) {
    if (src.isEmpty || dst.isEmpty) return null;

    final begin = _characters.indexOf(src);
    final end = _characters.indexOf(dst);

    if (begin < 0 || end < 0) return null;

    // [Metrics] between precache ranges
    for (var i = begin; i <= end; i++) {
      getCharMetrics(_characters[i]);
    }
    return (begin: begin, end: end);
  }

  /// Get [TextPainter]
  TextPainter _obtainTextPainter(String char) {
    TextPainter tp;
    try {
      tp = _tps.removeFirst();
    } catch (_) {
      tp = TextPainter(textDirection: TextDirection.ltr);
    }
    tp.text = TextSpan(text: char, style: _style);
    return tp;
  }

  /// Recycle [TextPainter]
  void _recycleTextPainter([bool dispose = false]) {
    metrics.removeWhere((key, value) {
      if (dispose) {
        // debugPrint('dispose(${value.char} ${value._tp.text?.style})');
        value._tp.dispose();
      } else {
        _tps.add(value._tp);
      }
      return true;
    });
  }

  void dispose() {
    _recycleTextPainter(true);
  }
}

/// Draw indicators
class Metrics {
  Metrics(this._tp) {
    // var n = DateTime.now();
    _tp.layout();
    // debugPrint('layout($char) ${DateTime.now().millisecond - n.millisecond}Ms');
    textWidth = _tp.width;
    textHeight = _tp.height;
    baseLineHeight =
        _tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  }

  /// Text painter
  final TextPainter _tp;

  /// Character width
  late final double textWidth;

  /// Character height
  late final double textHeight;

  /// Baseline height
  late final double baseLineHeight;

  /// Corresponding character
  String get char => _tp.plainText;

  /// Paint content
  void paint(Canvas canvas, Offset offset) {
    // canvas.drawRect(
    //   offset & Size(_tp.width, _tp.height),
    //   Paint()
    //     ..color = Colors.black
    //     ..style = PaintingStyle.stroke,
    // );
    _tp.paint(canvas, offset);
  }
}
