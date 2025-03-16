import 'dart:math';

/// 编辑的操作
enum Action {
  /// 替换
  replace,

  /// 插入
  insert,

  /// 删除
  delete;
}

/// 计算每列的操作
Iterable<Action> computeColumnActions(
  String source,
  String target,
  String supportedCharacters,
) {
  var sourceIndex = 0;
  var targetIndex = 0;

  final columnActions = <Action>[];
  while (true) {
    // 终止条件
    final reachedEndOfSource = sourceIndex == source.length;
    final reachedEndOfTarget = targetIndex == target.length;
    if (reachedEndOfSource && reachedEndOfTarget) {
      break;
    } else if (reachedEndOfSource) {
      columnActions
          .addAll(List.filled(target.length - targetIndex, Action.insert));
      break;
    } else if (reachedEndOfTarget) {
      columnActions
          .addAll(List.filled(source.length - sourceIndex, Action.delete));
      break;
    }

    final sourceChar = supportedCharacters.contains(source[sourceIndex]);
    final targetChar = supportedCharacters.contains(target[targetIndex]);

    if (sourceChar && targetChar) {
      // 对字符串都支持的部分计算编辑操作
      final sourceEndIndex = _findNextUnsupportedChar(
        source,
        sourceIndex + 1,
        supportedCharacters,
      );
      final targetEndIndex = _findNextUnsupportedChar(
        target,
        targetIndex + 1,
        supportedCharacters,
      );

      final actions = levenshteinDistanceActions(
        source.substring(sourceIndex, sourceEndIndex),
        target.substring(targetIndex, targetEndIndex),
      );
      columnActions.addAll(actions);
      sourceIndex = sourceEndIndex;
      targetIndex = targetEndIndex;
    } else if (sourceChar) {
      // 目标字符不被支持，将其插入
      columnActions.add(Action.insert);
      targetIndex++;
    } else if (targetChar) {
      // 原字符不被支持，将其删除
      columnActions.add(Action.delete);
      sourceIndex++;
    } else {
      // 两个字符都不被支持做替换操作
      columnActions.add(Action.replace);
      sourceIndex++;
      targetIndex++;
    }
  }

  return columnActions;
}

/// 查找下一个不被支持的字符索引
int _findNextUnsupportedChar(
  String chars,
  int startIndex,
  String supportedCharacters,
) {
  for (int i = startIndex; i < chars.length; i++) {
    if (!supportedCharacters.contains(chars[i])) {
      return i;
    }
  }
  return chars.length;
}

/// 莱文斯坦距离所做的操作
/// [source] 源字符串
/// [target] 目标字符串
///
/// 返回每个字符串的编辑操作列表
Iterable<Action> levenshteinDistanceActions(String source, String target) {
  // 长度相等时所有字符应用[Actions.replace]
  if (source.length == target.length) {
    final resultLen = max(source.length, target.length);
    return List.filled(resultLen, Action.replace);
  }

  final (_, matrix) = levenshteinDistance(source, target);

  // 反向追踪矩阵以计算必要的操作
  final actions = <Action>[];
  var row = source.length, col = target.length;
  while (row > 0 || col > 0) {
    if (row == 0) {
      // 源字符串已追踪完，到达顶行，只能向左移动，即插入列
      actions.add(Action.insert);
      col--;
    } else if (col == 0) {
      // 目标字符串已追踪完，达到最左边一列，只能向上移动，即删除列
      actions.add(Action.delete);
      row--;
    } else {
      final int insert = matrix[row][col - 1];
      final int delete = matrix[row - 1][col];
      final int replace = matrix[row - 1][col - 1];

      if (insert < delete && insert < replace) {
        actions.add(Action.insert);
        col--;
      } else if (delete < replace) {
        actions.add(Action.delete);
        row--;
      } else {
        actions.add(Action.replace);
        row--;
        col--;
      }
    }
  }

  // 颠倒操作以获得正确的顺序
  return actions.reversed;
}

/// 莱文斯坦距离
/// https://en.wikipedia.org/wiki/Levenshtein_distance
/// [source] 源字符串
/// [target] 目标字符串
///
/// 返回
/// [distance] 编辑距离
/// [matrix] 包含编辑步骤的矩阵
(int distance, List<List<int>> matrix) levenshteinDistance(
  String source,
  String target,
) {
  final srcLen = source.length, tarLen = target.length;
  final numRows = srcLen + 1, numCols = tarLen + 1;
  final matrix = List.generate(numRows, (index) => List.filled(numCols, 0));

  for (int i = 0; i < numRows; i++) {
    matrix[i][0] = i;
  }
  for (int j = 0; j < numCols; j++) {
    matrix[0][j] = j;
  }

  var cost = 0;
  for (int row = 1; row < numRows; row++) {
    for (int col = 1; col < numCols; col++) {
      cost = source.codeUnitAt(row - 1) == target.codeUnitAt(col - 1) ? 0 : 1;
      matrix[row][col] = _min(
        matrix[row - 1][col] + 1,
        matrix[row][col - 1] + 1,
        matrix[row - 1][col - 1] + cost,
      );
    }
  }

  final distance = matrix[srcLen][tarLen];

  return (distance, List.unmodifiable(matrix));
}

/// 比较三数的最小值
T _min<T extends num>(T a, T b, T c) {
  return a < b ? (a < c ? a : c) : (b < c ? b : c);
}
