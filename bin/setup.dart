import 'dart:io';

Future<void> main(List<String> args) async {
  final useAndroid = args.contains('--android');
  final useIos = args.contains('--ios');
  final useBoth = args.contains('--both') || (!useAndroid && !useIos);

  final scaffoldAndroid = useBoth || useAndroid;
  final scaffoldIos = useBoth || useIos;

  final created = <String>[];
  final skipped = <String>[];

  if (!File('pubspec.yaml').existsSync()) {
    _logError('pubspec.yaml not found. Run setup at Flutter project root.');
    exitCode = 2;
    return;
  }

  _logInfo('Running flutter_pro_architect setup...');

  final commonDirs = <String>[
    'lib/core/error',
    'lib/core/network',
    'lib/core/usecase',
    'lib/features',
    'lib/injection',
  ];

  final androidDirs = <String>[
    'android/app/src/main/kotlin',
    'android/app/src/main/res',
  ];

  final iosDirs = <String>[
    'ios/Runner',
    'ios/Runner/Assets.xcassets',
  ];

  for (final dir in commonDirs) {
    await _createDir(dir, created, skipped);
  }
  if (scaffoldAndroid) {
    for (final dir in androidDirs) {
      await _createDir(dir, created, skipped);
    }
  }
  if (scaffoldIos) {
    for (final dir in iosDirs) {
      await _createDir(dir, created, skipped);
    }
  }

  final files = <String, String>{
    'lib/core/error/failure.dart': _failureTemplate,
    'lib/core/usecase/usecase.dart': _usecaseTemplate,
    'lib/injection/injection_container.dart': _injectionTemplate,
  };

  for (final entry in files.entries) {
    await _createFile(entry.key, entry.value, created, skipped);
  }

  _logSuccess('Setup completed.');
  _printSummary(created: created, skipped: skipped, android: scaffoldAndroid, ios: scaffoldIos);
}

Future<void> _createDir(
  String path,
  List<String> created,
  List<String> skipped,
) async {
  final dir = Directory(path);
  if (dir.existsSync()) {
    skipped.add(path);
    return;
  }
  await dir.create(recursive: true);
  created.add(path);
}

Future<void> _createFile(
  String path,
  String content,
  List<String> created,
  List<String> skipped,
) async {
  final file = File(path);
  if (file.existsSync()) {
    skipped.add(path);
    return;
  }
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
  created.add(path);
}

void _printSummary({
  required List<String> created,
  required List<String> skipped,
  required bool android,
  required bool ios,
}) {
  stdout.writeln('');
  stdout.writeln('${_cyan}Summary${_reset}');
  stdout.writeln('Target platforms: ${android ? 'Android ' : ''}${ios ? 'iOS' : ''}'.trim());
  stdout.writeln('Created: ${created.length}');
  for (final item in created) {
    stdout.writeln('  + $item');
  }
  stdout.writeln('Skipped: ${skipped.length}');
  for (final item in skipped) {
    stdout.writeln('  - $item');
  }
}

void _logInfo(String message) => stdout.writeln('$_cyan$message$_reset');
void _logSuccess(String message) => stdout.writeln('$_green$message$_reset');
void _logError(String message) => stderr.writeln('$_red$message$_reset');

const String _reset = '\u001b[0m';
const String _red = '\u001b[31m';
const String _green = '\u001b[32m';
const String _cyan = '\u001b[36m';

const String _failureTemplate = '''
class Failure {
  const Failure(this.message);

  final String message;
}
''';

const String _usecaseTemplate = '''
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
''';

const String _injectionTemplate = '''
void initInjection() {
  // Register app dependencies here.
}
''';
