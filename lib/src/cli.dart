import 'dart:io';

import 'package:args/args.dart';

import 'feature_generator.dart';
import 'name_utils.dart';

/// CLI entry service for generating feature modules with the
/// `create_bloc_<feature_name>` command format.
///
/// Example:
/// ```dart
/// final cli = FlutterProArchitectCli();
/// final code = await cli.run(['create_bloc_user']);
/// print(code);
/// ```
class FlutterProArchitectCli {
  /// Name of the executable command shown in usage help.
  ///
  /// Example:
  /// ```dart
  /// print(FlutterProArchitectCli.executableName);
  /// ```
  static const String executableName = 'flutter_pro_architect';

  /// Parses [arguments], validates command format, and generates a feature.
  ///
  /// Parameters:
  /// - [arguments]: Raw CLI arguments.
  ///
  /// Returns:
  /// - Exit code `0` on success, non-zero on failure.
  ///
  /// Example:
  /// ```dart
  /// final exitCode = await FlutterProArchitectCli().run(
  ///   ['create_bloc_auth', '--no-color'],
  /// );
  /// ```
  Future<int> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage')
      ..addFlag('no-color', negatable: false, help: 'Disable ANSI colors');

    ArgResults results;
    try {
      results = parser.parse(arguments);
    } on FormatException catch (e) {
      stderr.writeln('Error: ${e.message}');
      _printUsage(parser);
      return 64;
    }

    if (results['help'] as bool) {
      _printUsage(parser);
      return 0;
    }

    final colorEnabled = !(results['no-color'] as bool);
    final command = _extractCommand(arguments);
    if (command == null) {
      _printUsage(parser);
      return 64;
    }

    if (!command.startsWith('create_bloc_')) {
      stderr.writeln(_style('Unsupported command: $command', _Ansi.red, colorEnabled));
      _printUsage(parser);
      return 64;
    }

    final rawFeatureName = command.substring('create_bloc_'.length);
    final snake = toSnakeCase(rawFeatureName);
    if (snake.isEmpty || snake == '_') {
      stderr.writeln(_style('Invalid feature name in command: $command', _Ansi.red, colorEnabled));
      return 64;
    }

    if (!File('pubspec.yaml').existsSync()) {
      stderr.writeln(
        _style('Run this command in a Flutter project root (missing pubspec.yaml).', _Ansi.red, colorEnabled),
      );
      return 2;
    }

    final generator = FeatureGenerator(colorEnabled: colorEnabled);
    final summary = await generator.generate(snake);

    for (final message in summary.messages) {
      stdout.writeln(message);
    }

    if (!summary.success) {
      return 1;
    }

    stdout.writeln(_style('Feature "$snake" generated successfully.', _Ansi.green, colorEnabled));
    return 0;
  }

  String? _extractCommand(List<String> arguments) {
    final nonFlags = arguments.where((arg) => !arg.startsWith('-')).toList();
    if (nonFlags.isNotEmpty) {
      return nonFlags.first;
    }

    final invoked = Platform.script.pathSegments.isEmpty
        ? ''
        : Platform.script.pathSegments.last.split('.').first;
    if (invoked.startsWith('create_bloc_')) {
      return invoked;
    }
    return null;
  }

  void _printUsage(ArgParser parser) {
    stdout.writeln('Usage: $executableName create_bloc_<feature_name> [--no-color]');
    stdout.writeln('Examples:');
    stdout.writeln('  $executableName create_bloc_user');
    stdout.writeln('  $executableName create_bloc_auth');
    stdout.writeln('Options:\n${parser.usage}');
  }

  String _style(String value, String ansi, bool enabled) {
    if (!enabled) return value;
    return '$ansi$value${_Ansi.reset}';
  }
}

class _Ansi {
  static const String reset = '\u001b[0m';
  static const String red = '\u001b[31m';
  static const String green = '\u001b[32m';
}
