import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'character_set.dart';
import 'ticker_column.dart';

class Ticker extends StatefulWidget {
  /// Display text
  final String text;

  /// Text style
  final TextStyle? style;

  /// Text alignment direction
  final TickerAlignment alignment;

  /// Animation duration
  final Duration duration;

  /// Animation curve
  final Curve curve;

  /// Character set with scroll variation support
  final TickerCharacters characters;

  /// Clip behavior
  /// Default [Clip.antiAlias]
  final Clip clipBehavior;

  const Ticker({
    super.key,
    required this.text,
    this.style,
    this.alignment = TickerAlignment.center,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.ease,
    this.characters = numberCharacters,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<Ticker> createState() => _TickerState();
}

class _TickerState extends State<Ticker> with TickerProviderStateMixin {
  /// Text effective style
  TextStyle get _effectiveStyle =>
      widget.style ?? DefaultTextStyle.of(context).style;

  @override
  Widget build(BuildContext context) {
    return _Ticker(
      vsync: this,
      text: widget.text,
      style: _effectiveStyle,
      alignment: widget.alignment,
      characters: widget.characters,
      duration: widget.duration,
      curve: widget.curve,
      clipBehavior: widget.clipBehavior,
    );
  }
}

class _Ticker extends LeafRenderObjectWidget {
  /// Display text
  final String text;

  /// Character set with scroll variation support
  final TickerCharacters characters;

  /// Text style
  final TextStyle? style;

  /// Clip behavior
  /// Default [Clip.antiAlias]
  final Clip clipBehavior;

  /// [TickerProvider] required for animation
  final TickerProvider vsync;

  /// Animation curve
  final Curve curve;

  /// Animation duration
  final Duration duration;

  /// Text alignment direction
  final TickerAlignment alignment;

  const _Ticker({
    super.key, // ignore: unused_element_parameter
    required this.text,
    required this.characters,
    required this.vsync,
    required this.duration,
    this.style,
    this.curve = Curves.linear,
    this.clipBehavior = Clip.antiAlias,
    this.alignment = TickerAlignment.center,
  });

  @override
  _TickerRenderer createRenderObject(BuildContext context) {
    return _TickerRenderer(
      text: text,
      characters: characters,
      style: style,
      alignment: alignment,
      vsync: vsync,
      duration: duration,
      curve: curve,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _TickerRenderer renderObject) {
    renderObject
      ..text = text
      ..characters = characters
      ..style = style
      ..alignment = alignment
      ..vsync = vsync
      ..duration = duration
      ..curve = curve
      ..clipBehavior = clipBehavior;
  }
}

class _TickerRenderer extends RenderBox {
  _TickerRenderer({
    required String text,
    required TickerCharacters characters,
    required TickerProvider vsync,
    required Duration duration,
    Curve curve = Curves.linear,
    Clip clipBehavior = Clip.antiAlias,
    TickerAlignment alignment = TickerAlignment.center,
    TextStyle? style,
  })  : _vsync = vsync,
        _text = text,
        _characters = characters,
        _style = style,
        _alignment = alignment,
        _clipBehavior = clipBehavior {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
      value: 1,
    )..addListener(() {
        if (_controller.value != _lastValue) {
          markNeedsLayout();
        }
      });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
    _columnManager = TickerColumnManager(
      source: text,
      characters: characters,
      listenable: _animation,
      style: style,
    );
  }

  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  late final TickerColumnManager _columnManager;
  double? _lastValue;
  Size? _internalSize;
  Rect? _clip;

  ///  Display text
  String get text => _text;
  String _text;

  set text(String value) {
    if (value == _text) return;

    _text = value;
    _columnManager.setText(text);
    _controller.forward(from: 0);
  }

  /// Character set with scroll variation support
  TickerCharacters get characters => _characters;
  TickerCharacters _characters;

  set characters(TickerCharacters value) {
    if (characters == value) return;

    _characters = value;
    _columnManager.setCharacterSet(characters);
  }

  /// Text style
  TextStyle? get style => _style;
  TextStyle? _style;

  set style(TextStyle? value) {
    if (_style == value) return;

    _style = value;
    _columnManager.setStyle(style);
    _controller.forward(from: 0);
  }

  /// Effective alignment direction
  TickerAlignment get effectiveAlignment => _internalAlignment ?? _alignment;

  TickerAlignment get alignment => _alignment;
  TickerAlignment _alignment;
  TickerAlignment? _internalAlignment;

  set alignment(TickerAlignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  /// [TickerProvider] required for animation
  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;

  set vsync(TickerProvider value) {
    if (value == _vsync) {
      return;
    }
    _vsync = value;
    _controller.resync(vsync);
  }

  /// Animation duration
  Duration get duration => _controller.duration!;

  set duration(Duration value) {
    if (value == _controller.duration) {
      return;
    }
    _controller.duration = value;
  }

  /// Animation curve
  Curve get curve => _animation.curve;

  set curve(Curve value) {
    if (value == _animation.curve) {
      return;
    }
    _animation.curve = value;
  }

  /// Clip behavior
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior;

  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    _lastValue = _controller.value;
    final constraints = this.constraints;
    _internalSize = _columnManager.onMeasure(constraints);
    size = constraints.constrain(_internalSize!);
    _clip =
        Offset.zero & Size(size.width, min(_internalSize!.height, size.height));
    // Force start alignment on overflow
    if (size.width < _internalSize!.width) {
      _internalAlignment = TickerAlignment.start;
    } else {
      _internalAlignment = null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (clipBehavior != Clip.none) {
      layer = context.pushClipRect(
        needsCompositing,
        offset,
        _clip!,
        _paintContent,
        clipBehavior: clipBehavior,
        oldLayer: layer as ClipRectLayer?,
      );
    } else {
      _paintContent(context, offset);
      layer = null;
    }
  }

  /// Render actual content
  void _paintContent(PaintingContext context, Offset offset) {
    assert(_internalSize != null);
    final dx = effectiveAlignment.inscribe(
      size.width,
      _columnManager.currentWidth,
    );
    _columnManager.paint(context.canvas, offset.translate(dx, 0));
  }

  @override
  void dispose() {
    _columnManager.dispose();
    super.dispose();
  }
}

/// Text alignment direction
class TickerAlignment {
  const TickerAlignment(this.value);

  /// Start alignment
  static const start = TickerAlignment(-1);

  /// Center alignment
  static const center = TickerAlignment(0);

  /// End alignment
  static const end = TickerAlignment(1);

  /// Alignment value
  final double value;

  double inscribe(double src, double dst) {
    final halfDelta = (src - dst) / 2;
    return halfDelta + value * halfDelta;
  }
}
