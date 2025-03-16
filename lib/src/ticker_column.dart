import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ticker/src/character_set.dart';
import 'package:flutter_ticker/src/draw_metrics.dart';
import 'package:flutter_ticker/src/levenshtein_distance.dart';
import 'package:flutter_ticker/src/utils.dart';

/// 每列字符管理器
class TickerColumnManager {
  TickerColumnManager({
    required String source,
    required String characters,
    required ValueListenable<double> listenable,
    TextStyle? style,
  })  : _characters = characters,
        _listenable = listenable,
        _metrics = CharMetrics(characters, style) {
    setText(source);
    _onProgressChanged();
    _listenable.addListener(_onProgressChanged);
  }

  /// 字符指标
  final CharMetrics _metrics;

  /// 每列集合
  final _columns = <TickerColumn>[];

  final ValueListenable<double> _listenable;

  /// 支持的字符集合
  TickerCharacters _characters;

  /// 源字符串
  String _source = '';

  /// 设置支持的字符集合
  void setCharacterSet(TickerCharacters characters) {
    if (_characters == characters) return;

    _characters = characters;
    _metrics.characters = characters;
    for (var column in _columns) {
      column.setCharacters(characters);
    }
  }

  /// 设置新的文本
  void setText(String text) {
    if (_source == text) return;

    // 清除零宽列
    final copy = List.of(_columns);
    for (var column in copy) {
      if (column.implicitWidth.nearZero()) {
        _columns.remove(column);
      }
    }

    // 计算字符编辑步骤
    final actions = computeColumnActions(_source, text, _characters);
    _source = text;
    int tIndex = 0, cIndex = 0;
    for (var i = 0; i < actions.length; i++) {
      switch (actions.elementAt(i)) {
        case Action.replace:
          _columns[cIndex].char = text[tIndex];
          tIndex++;
          break;
        case Action.insert:
          final column = TickerColumn(text[tIndex], _metrics, _characters);
          _columns.insert(cIndex, column);
          tIndex++;
          break;
        case Action.delete:
          _columns[cIndex].char = emptyChar;
          break;
      }
      cIndex++;
    }
  }

  /// 更新文本样式
  void setStyle(TextStyle? value) {
    _metrics.style = value;
    for (var column in _columns) {
      column._onMeasure();
    }
  }

  /// 动画进度发生变化
  void _onProgressChanged() {
    final value = _listenable.value;
    for (var column in _columns) {
      column.onProgressChanged(value);
    }
  }

  /// 获取当前的宽度
  double get currentWidth {
    double width = 0;
    for (var column in _columns) {
      width += column.width;
    }
    return width;
  }

  /// 测量
  Size onMeasure(BoxConstraints constraints) {
    double height = 0, width = 0;
    for (var column in _columns) {
      height = max(height, column.implicitHeight);
      width += column.width;
    }
    return Size(width, height);
  }

  /// 绘制
  void paint(Canvas canvas, Offset offset) {
    for (var column in _columns) {
      column.paint(canvas, offset);
      canvas.translate(column.width, 0);
    }
  }

  /// 销毁
  void dispose() {
    _listenable.removeListener(_onProgressChanged);
    _metrics.dispose();
  }
}

/// 字符列状态
class TickerColumn {
  TickerColumn(String char, this._metrics, this._characters) {
    this.char = char;
  }

  /// 字符指标
  final CharMetrics _metrics;

  /// 用于当前列变化的字符列表
  String _charSequence = '';

  /// 当前显示的字符
  String _char = emptyChar;

  set char(String value) {
    final indexes = _metrics.getCharIndexes(_char, value);
    if (indexes != null) {
      _beginIndex = indexes.begin;
      _endIndex = indexes.end;
      _charSequence = _characters;
    } else if (_char == value) {
      _charSequence = value;
      _beginIndex = _endIndex = 0;
    } else {
      _charSequence = "$_char$value";
      _beginIndex = 0;
      _endIndex = 1;
    }
    _char = value;
    _onMeasure();
  }

  /// 字符集
  TickerCharacters _characters;

  void setCharacters(TickerCharacters characters) {
    _characters = characters;
  }

  /// 索引
  int _beginIndex = 0, _endIndex = 0, _charIndex = 0;

  /// 根据索引位置变化产生的y轴偏移值
  double _yOffset = 0;

  /// 当前动态宽度
  double get width => _width;
  double _width = 0;

  /// 隐式高度
  double get implicitHeight => _implicitHeight;
  double _implicitHeight = 0;

  /// 隐式宽度（目标宽度）
  double get implicitWidth => _implicitWidth;
  double _implicitWidth = 0, _lastImplicitWidth = 0;

  /// 动画进度更新
  void onProgressChanged(double value) {
    _width = lerpDouble(_lastImplicitWidth, _implicitWidth, value)!;
    final indexProgress = lerpDouble(_beginIndex, _endIndex, value)!;
    _charIndex = indexProgress.floor();
    var yPercent = indexProgress % 1;
    _yOffset = implicitHeight * yPercent * -1;

    if (value.nearEqual(1)) {
      _beginIndex = _endIndex;
    }
  }

  /// 测量字符尺寸
  void _onMeasure() {
    final metrics = _metrics.getCharMetrics(_char);
    _lastImplicitWidth = implicitWidth;
    _implicitWidth = metrics.textWidth;
    _implicitHeight = metrics.textHeight;
    // debugPrint('[$_char]${_implicitWidth}x$_implicitHeight');
  }

  /// 绘制内容
  void paint(Canvas canvas, Offset offset) {
    _drawText(_charIndex - 1, canvas, offset, _yOffset - implicitHeight);
    _drawText(_charIndex, canvas, offset, _yOffset);
    _drawText(_charIndex + 1, canvas, offset, _yOffset + implicitHeight);
  }

  /// 绘制文本
  void _drawText(int index, Canvas canvas, Offset offset, double dy) {
    if (index < 0 || index >= _charSequence.length) return;

    final char = _charSequence[index];
    offset = offset.translate(0, dy);
    _metrics.getCharMetrics(char).paint(canvas, offset);
  }
}
