import 'dart:math';

/// Edit operations
enum Action {
  replace,
  insert,
  delete;
}

/// Computes operations for each column.
Iterable<Action> computeColumnActions(
  String source,
  String target,
  String supportedCharacters,
) {
  var sourceIndex = 0;
  var targetIndex = 0;

  final columnActions = <Action>[];
  while (true) {
    // Check for terminating conditions
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

    final containsSrcChar = supportedCharacters.contains(source[sourceIndex]);
    final containsDstChar = supportedCharacters.contains(target[targetIndex]);

    if (containsSrcChar && containsDstChar) {
      // Calculate edit operations for concurrently supported characters.
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
    } else if (containsSrcChar) {
      // The target character is not supported; insert it.
      columnActions.add(Action.insert);
      targetIndex++;
    } else if (containsDstChar) {
      // The source character is not supported; delete it.
      columnActions.add(Action.delete);
      sourceIndex++;
    } else {
      // Neither character is supported for replacement operation.
      columnActions.add(Action.replace);
      sourceIndex++;
      targetIndex++;
    }
  }

  return columnActions;
}

/// Find index of next unsupported char
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

/// Levenshtein distance operations
/// [source] source string
/// [target] target string
///
/// Returns list of edit operations per string
Iterable<Action> levenshteinDistanceActions(String source, String target) {
  // Apply [Actions.replace] to all characters when lengths are equal.
  if (source.length == target.length) {
    final resultLen = max(source.length, target.length);
    return List.filled(resultLen, Action.replace);
  }

  final (_, matrix) = levenshteinDistance(source, target);

  // Reverse traversal to generate required operations
  final actions = <Action>[];
  var row = source.length, col = target.length;
  while (row > 0 || col > 0) {
    if (row == 0) {
      // At the top row, can only move left, meaning insert column
      actions.add(Action.insert);
      col--;
    } else if (col == 0) {
      // At the left column, can only move up, meaning delete column
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

  // Reverse the actions to get the correct ordering
  return actions.reversed;
}

/// Levenshtein distance
/// https://en.wikipedia.org/wiki/Levenshtein_distance
/// [source] Source string
/// [target] Target string
///
/// Returns
/// [distance] Edit Distance
/// [matrix] Matrix containing editing steps
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

/// Comparing the minimum value of the three numbers
T _min<T extends num>(T a, T b, T c) {
  return a < b ? (a < c ? a : c) : (b < c ? b : c);
}
