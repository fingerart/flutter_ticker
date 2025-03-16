import 'package:flutter/foundation.dart';

const emptyChar = '\u200B';

extension DoubleExt on double? {
  /// 两个值是否近似相等
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

  /// 是否近似等于0
  /// [epsilon] 允许的误差
  bool nearZero({
    double epsilon = precisionErrorTolerance,
  }) {
    return nearEqual(0.0, epsilon: epsilon);
  }
}
