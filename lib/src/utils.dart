import 'package:flutter/foundation.dart';

const emptyChar = '\u200B';

extension DoubleExt on double? {
  /// Check approximate equality
  bool nearEqual(
    double? other, {
    double epsilon = precisionErrorTolerance,
  }) {
    assert(epsilon >= 0.0);
    if (this == null || other == null) {
      return this == other;
    }
    return (this! > (other - epsilon)) && (this! < (other + epsilon)) ||
        this == other;
  }

  /// Check if approximately zero
  /// [epsilon] tolerance threshold
  bool nearZero({
    double epsilon = precisionErrorTolerance,
  }) {
    return nearEqual(0.0, epsilon: epsilon);
  }
}
