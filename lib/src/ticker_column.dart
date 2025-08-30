import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ticker/src/character_set.dart';
import 'package:flutter_ticker/src/draw_metrics.dart';
import 'package:flutter_ticker/src/levenshtein_distance.dart';
import 'package:flutter_ticker/src/utils.dart';

/// Column character manager
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

  /// Character metrics
  final CharMetrics _metrics;

  /// Column collection
  final _columns = <TickerColumn>[];

  final ValueListenable<double> _listenable;

  /// Character set with scroll variation support
  TickerCharacters _characters;

  /// Source string
  String _source = '';

  /// Set supported character set
  void setCharacterSet(TickerCharacters characters) {
    if (_characters == characters) return;

    _characters = characters;
    _metrics.characters = characters;
    for (var column in _columns) {
      column.setCharacters(characters);
    }
  }

  /// Set new text
  void setText(String text) {
    if (_source == text) return;

    // Clear zero-width columns
    final copy = List.of(_columns);
    for (var column in copy) {
      if (column.implicitWidth.nearZero()) {
        _columns.remove(column);
      }
    }

    // Calculate character edit steps
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

  /// Update text style
  void setStyle(TextStyle? value) {
    _metrics.style = value;
    for (var column in _columns) {
      column._onMeasure();
    }
  }

  /// Animation progress changed
  void _onProgressChanged() {
    final value = _listenable.value;
    for (var column in _columns) {
      column.onProgressChanged(value);
    }
  }

  /// Get current width
  double get currentWidth {
    double width = 0;
    for (var column in _columns) {
      width += column.width;
    }
    return width;
  }

  /// Measure overall dimensions
  Size onMeasure(BoxConstraints constraints) {
    double height = 0, width = 0;
    for (var column in _columns) {
      height = max(height, column.implicitHeight);
      width += column.width;
    }
    return Size(width, height);
  }

  /// Draw column contents
  void paint(Canvas canvas, Offset offset) {
    for (var column in _columns) {
      column.paint(canvas, offset);
      canvas.translate(column.width, 0);
    }
  }

  /// Destroy
  void dispose() {
    _listenable.removeListener(_onProgressChanged);
    _metrics.dispose();
  }
}

/// Character column state
class TickerColumn {
  TickerColumn(String char, this._metrics, this._characters) {
    this.char = char;
  }

  /// Character metrics
  final CharMetrics _metrics;

  /// Character list for column changes
  String _charSequence = '';

  /// Currently displayed character
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

  /// Character set with scroll variation support
  TickerCharacters _characters;

  void setCharacters(TickerCharacters characters) {
    _characters = characters;
  }

  /// Indexes
  int _beginIndex = 0, _endIndex = 0, _charIndex = 0;

  /// Y-offset from index position change
  double _yOffset = 0;

  /// Current dynamic width
  double get width => _width;
  double _width = 0;

  /// Implicit height
  double get implicitHeight => _implicitHeight;
  double _implicitHeight = 0;

  /// Implicit width (target)
  double get implicitWidth => _implicitWidth;
  double _implicitWidth = 0, _lastImplicitWidth = 0;

  /// Handle animation progress update
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

  /// Measure character dimensions
  void _onMeasure() {
    final metrics = _metrics.getCharMetrics(_char);
    _lastImplicitWidth = implicitWidth;
    _implicitWidth = metrics.textWidth;
    _implicitHeight = metrics.textHeight;
    // debugPrint('[$_char]${_implicitWidth}x$_implicitHeight');
  }

  /// Draw character content
  void paint(Canvas canvas, Offset offset) {
    _drawText(_charIndex - 1, canvas, offset, _yOffset - implicitHeight);
    _drawText(_charIndex, canvas, offset, _yOffset);
    _drawText(_charIndex + 1, canvas, offset, _yOffset + implicitHeight);
  }

  /// Draw single character
  void _drawText(int index, Canvas canvas, Offset offset, double dy) {
    if (index < 0 || index >= _charSequence.length) return;

    final char = _charSequence[index];
    offset = offset.translate(0, dy);
    _metrics.getCharMetrics(char).paint(canvas, offset);
  }
}
