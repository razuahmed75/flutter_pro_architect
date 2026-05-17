/// Converts any input text to `snake_case`.
///
/// Parameters:
/// - [input]: Raw feature name or identifier to normalize.
///
/// Returns:
/// - A normalized `snake_case` string containing only lowercase alphanumeric
///   characters and underscores.
///
/// Example:
/// ```dart
/// final snake = toSnakeCase('UserProfileV2');
/// // snake == 'user_profile_v2'
/// ```
String toSnakeCase(String input) {
  final normalized = input
      .replaceAll(RegExp(r'([a-z0-9])([A-Z])'), r'$1_$2')
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
      .toLowerCase()
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized;
}

/// Converts any input text to `PascalCase`.
///
/// Parameters:
/// - [input]: Raw feature name or identifier to normalize.
///
/// Returns:
/// - A normalized `PascalCase` string.
///
/// Example:
/// ```dart
/// final pascal = toPascalCase('user_profile');
/// // pascal == 'UserProfile'
/// ```
String toPascalCase(String input) {
  final snake = toSnakeCase(input);
  if (snake.isEmpty) return '';
  return snake
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join();
}
