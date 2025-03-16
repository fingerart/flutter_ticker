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

  /// 文本样式
  TextStyle? _style;

  set style(TextStyle? value) {
    if (value == _style) return;
    _recycleTextPainter();
    _style = value;
  }

  /// 获取字符的指标
  Metrics getCharMetrics(String char) {
    return metrics.putIfAbsent(Object.hash(char, _style), () {
      return Metrics(_obtainTextPainter(char));
    });
  }

  /// 获取[src]和[dst]的索引
  ({int begin, int end})? getCharIndexes(String src, String dst) {
    if (src.isEmpty || dst.isEmpty) return null;

    final begin = _characters.indexOf(src);
    final end = _characters.indexOf(dst);

    if (begin < 0 || end < 0) return null;

    // 预热范围之间的[Metrics]
    for (var i = begin; i <= end; i++) {
      getCharMetrics(_characters[i]);
    }
    return (begin: begin, end: end);
  }

  /// 获取[TextPainter]
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

  /// 回收[TextPainter]
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

/// 绘制指标
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

  /// 文本绘制器
  final TextPainter _tp;

  /// 字符宽度
  late final double textWidth;

  /// 字符高度
  late final double textHeight;

  /// 基线高度
  late final double baseLineHeight;

  /// 对应的字符
  String get char => _tp.plainText;

  /// 绘制内容
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
