import 'dart:io';

import 'name_utils.dart';
import 'templates.dart';

/// Result contract for a generation run.
///
/// Example:
/// ```dart
/// final summary = GenerationSummary(success: true, messages: ['Done']);
/// print(summary.success);
/// ```
class GenerationSummary {
  /// Creates a generation summary object.
  ///
  /// Parameters:
  /// - [success]: Indicates whether generation completed successfully.
  /// - [messages]: Human-readable logs produced during generation.
  ///
  /// Returns:
  /// - A [GenerationSummary] instance.
  ///
  /// Example:
  /// ```dart
  /// final summary = GenerationSummary(
  ///   success: false,
  ///   messages: ['Feature already exists'],
  /// );
  /// ```
  GenerationSummary({required this.success, required this.messages});

  /// Indicates whether generation was successful.
  ///
  /// Example:
  /// ```dart
  /// if (summary.success) {
  ///   print('ok');
  /// }
  /// ```
  final bool success;

  /// Ordered log messages generated during scaffolding.
  ///
  /// Example:
  /// ```dart
  /// for (final line in summary.messages) {
  ///   print(line);
  /// }
  /// ```
  final List<String> messages;
}

/// Generates a complete feature module using package templates.
///
/// Example:
/// ```dart
/// final generator = FeatureGenerator(colorEnabled: false);
/// final summary = await generator.generate('user');
/// print(summary.success);
/// ```
class FeatureGenerator {
  /// Creates a feature generator instance.
  ///
  /// Parameters:
  /// - [colorEnabled]: Enables ANSI color in generated logs.
  ///
  /// Returns:
  /// - A [FeatureGenerator] configured for the current run.
  ///
  /// Example:
  /// ```dart
  /// final generator = FeatureGenerator(colorEnabled: true);
  /// ```
  FeatureGenerator({required this.colorEnabled});

  /// Whether generated terminal logs include ANSI color styling.
  ///
  /// Example:
  /// ```dart
  /// print(generator.colorEnabled);
  /// ```
  final bool colorEnabled;

  /// Generates core files and a feature module for [featureSnake].
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  ///
  /// Returns:
  /// - A [GenerationSummary] describing created and skipped files.
  ///
  /// Example:
  /// ```dart
  /// final result = await generator.generate('product');
  /// print(result.messages.join('\n'));
  /// ```
  Future<GenerationSummary> generate(String featureSnake) async {
    final messages = <String>[];
    final featureRoot = Directory('lib/features/$featureSnake');
    if (featureRoot.existsSync()) {
      return GenerationSummary(
        success: false,
        messages: [
          _style('Feature already exists: lib/features/$featureSnake', _Ansi.red),
          _style('Skipping generation to avoid overwriting existing module.', _Ansi.yellow),
        ],
      );
    }

    final coreFiles = <String, String>{
      'lib/core/usecase/usecase.dart': Templates.coreUseCase(),
      'lib/core/error/failure.dart': Templates.coreFailure(),
    };

    for (final entry in coreFiles.entries) {
      final file = File(entry.key);
      if (file.existsSync()) {
        messages.add(_style('Exists: ${entry.key}', _Ansi.yellow));
        continue;
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(entry.value);
      messages.add(_style('Created: ${entry.key}', _Ansi.green));
    }

    final featurePascal = toPascalCase(featureSnake);

    final files = <String, String>{
      'lib/features/$featureSnake/data/datasources/${featureSnake}_remote_datasource.dart':
          Templates.remoteDataSource(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/data/models/${featureSnake}_model.dart':
          Templates.model(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/data/repositories/${featureSnake}_repository_impl.dart':
          Templates.repositoryImpl(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/entities/${featureSnake}_entity.dart':
          Templates.entity(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/repositories/${featureSnake}_repository.dart':
          Templates.repository(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/usecases/get_${featureSnake}s_usecase.dart':
          Templates.getItemsUseCase(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/usecases/get_${featureSnake}_by_id_usecase.dart':
          Templates.getItemByIdUseCase(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/usecases/create_${featureSnake}_usecase.dart':
          Templates.createItemUseCase(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/usecases/update_${featureSnake}_usecase.dart':
          Templates.updateItemUseCase(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/usecases/patch_${featureSnake}_usecase.dart':
          Templates.patchItemUseCase(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/domain/usecases/delete_${featureSnake}_usecase.dart':
          Templates.deleteItemUseCase(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/presentation/bloc/${featureSnake}_bloc.dart':
          Templates.bloc(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/presentation/bloc/${featureSnake}_event.dart':
          Templates.event(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/presentation/bloc/${featureSnake}_state.dart':
          Templates.state(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/presentation/pages/${featureSnake}_page.dart':
          Templates.page(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/presentation/widgets/${featureSnake}_card.dart':
          Templates.card(featureSnake: featureSnake, featurePascal: featurePascal),
      'lib/features/$featureSnake/${featureSnake}_injection.dart':
          Templates.injection(featureSnake: featureSnake, featurePascal: featurePascal),
    };

    for (final entry in files.entries) {
      final file = File(entry.key);
      await file.parent.create(recursive: true);
      await file.writeAsString(entry.value);
      messages.add(_style('Created: ${entry.key}', _Ansi.green));
    }

    return GenerationSummary(success: true, messages: messages);
  }

  String _style(String value, String ansi) {
    if (!colorEnabled) return value;
    return '$ansi$value${_Ansi.reset}';
  }
}

class _Ansi {
  static const String reset = '\u001b[0m';
  static const String red = '\u001b[31m';
  static const String green = '\u001b[32m';
  static const String yellow = '\u001b[33m';
}
