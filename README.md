# flutter_ticker

[![pub package](https://img.shields.io/pub/v/flutter_ticker.svg)](https://pub.dartlang.org/packages/flutter_ticker)
[![GitHub stars](https://img.shields.io/github/stars/fingerart/flutter_ticker)](https://github.com/fingerart/flutter_ticker/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fingerart/flutter_ticker)](https://github.com/fingerart/flutter_ticker/network)
[![GitHub license](https://img.shields.io/github/license/fingerart/flutter_ticker)](https://github.com/fingerart/flutter_ticker/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/fingerart/flutter_ticker)](https://github.com/fingerart/flutter_ticker/issues)

An Flutter text widget with scrolling text change animation.

> [!TIP]
> If this package is useful to you, please remember to give it a star✨ ([Pub](https://pub.dev/packages/flutter_ticker) | [GitHub](https://github.com/fingerart/flutter_ticker)).


## Preview

View [👆demo👆](https://fingerart.github.io/flutter_ticker) online.

| Ticker                                                                                                    | Timer & Progress                                                                             |
|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| ![flutter_ticker](https://raw.githubusercontent.com/fingerart/flutter_ticker/main/arts/demo.gif?raw=true) | ![](https://raw.githubusercontent.com/fingerart/flutter_ticker/main/arts/demo2.gif?raw=true) |


## Usage

```yaml
dependencies:
  flutter_ticker: ^0.0.1+3
```

```dart
import 'package:flutter_ticker/flutter_ticker.dart';

Ticker(
  text:'\$10.24',
)
```

## Support parameters

| Parameters   | Optional     | Default                  | Description                               |
|:-------------|:-------------|:-------------------------|-------------------------------------------|
| `text`       | **Required** |                          | Text content                              |
| `alignment`  | Optional     | `TickerAlignment.center` | Text alignment direction                  |
| `style`      | Optional     | Inherited from the theme | Text style                                |
| `duration`   | Optional     | 500Ms                    | Animation duration                        |
| `curve`      | Optional     | `Curves.ease`            | Animation curves                          |
| `characters` | Optional     | `0123456789`             | A collection of characters for animations |

## Other flutter widgets or dart library

- [flutter_hypertext](https://pub.dev/packages/flutter_hypertext): A highly extensible rich text widget that can automatically parse styles.
- [varint](https://pub.dev/packages/varint): A Dart library for encoding and decoding variable-length quantity (VLQ).

## Other

> This project is a flutter implementation of the [ticker](https://github.com/robinhood/ticker)
> project.