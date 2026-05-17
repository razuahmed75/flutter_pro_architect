String toSnakeCase(String input) {
  final normalized = input
      .replaceAll(RegExp(r'([a-z0-9])([A-Z])'), r'$1_$2')
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
      .toLowerCase()
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized;
}

String toPascalCase(String input) {
  final snake = toSnakeCase(input);
  if (snake.isEmpty) return '';
  return snake
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join();
}
