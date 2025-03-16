import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ticker/flutter_ticker.dart';
import 'package:flutter_ticker/src/levenshtein_distance.dart';

TickerCharacters number = "0123456789";

void main() {
  test('levenshteinDistance test', () {
    final (distance, matrix) = levenshteinDistance("1234", '2345');
    expect(distance, 2);
  });

  test('levenshteinDistanceActions test', () {
    Iterable<Action> actions = levenshteinDistanceActions('1234', '2345');
    expect(actions.toIndexString(), '0000');

    actions = levenshteinDistanceActions('15233', '9151');
    expect(actions.toIndexString(), '100220');
  });

  test('computeColumnActions test', () {
    Iterable<Action> actions = computeColumnActions('1234', '2345', number);
    expect(actions.toIndexString(), '0000');

    actions = computeColumnActions('15233', '9151', number);
    expect(actions.toIndexString(), '100220');

    actions = computeColumnActions('\$123.99', '\$1223.98', number);
    expect(actions.toIndexString(), '00010000');

    actions = computeColumnActions('\$1.0000', '\$1000.0', number);
    expect(actions.toIndexString(), '0011100222');

    actions = computeColumnActions('\$10.5.1', '\$10.51', number);
    expect(actions.toIndexString(), '00000122');
  });
}

extension _ActionsExt on Iterable<Action> {
  String toIndexString() => map((e) => e.index).join();
}
