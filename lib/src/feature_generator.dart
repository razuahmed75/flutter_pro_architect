import 'dart:io';

import 'name_utils.dart';
import 'templates.dart';

class GenerationSummary {
  GenerationSummary({required this.success, required this.messages});

  final bool success;
  final List<String> messages;
}

class FeatureGenerator {
  FeatureGenerator({required this.colorEnabled});

  final bool colorEnabled;

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
  static const reset = '\u001b[0m';
  static const red = '\u001b[31m';
  static const green = '\u001b[32m';
  static const yellow = '\u001b[33m';
}
