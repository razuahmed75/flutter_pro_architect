import 'dart:io';

/// Generator class for scaffolding the initial project structure and adding
/// essential packages.
class SetupGenerator {
  /// Whether to use ANSI colors in the output.
  final bool colorEnabled;

  /// Creates a new [SetupGenerator] instance.
  SetupGenerator({this.colorEnabled = true});

  /// Executes the setup process.
  ///
  /// Parameters:
  /// - [args]: CLI arguments to determine target platforms.
  ///
  /// Returns:
  /// - Exit code `0` on success, non-zero on failure.
  Future<int> run(List<String> args) async {
    final useAndroid = args.contains('--android');
    final useIos = args.contains('--ios');
    final useBoth = args.contains('--both') || (!useAndroid && !useIos);

    final scaffoldAndroid = useBoth || useAndroid;
    final scaffoldIos = useBoth || useIos;

    final created = <String>[];
    final skipped = <String>[];

    if (!File('pubspec.yaml').existsSync()) {
      _logError('pubspec.yaml not found. Run setup at Flutter project root.');
      return 2;
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

    // ── Add required packages ──────────────────────────────────────────
    _logInfo('\nAdding required packages...');

    final addedPackages = <String>[];
    final skippedPackages = <String>[];

    final pubspecContent = File('pubspec.yaml').readAsStringSync();

    for (final group in _packageGroups) {
      for (final pkg in group.packages) {
        if (_packageExists(pubspecContent, pkg)) {
          skippedPackages.add(pkg);
          _logSkip('  ⊘ $pkg (already exists)');
        } else {
          final success = await _addPackage(pkg);
          if (success) {
            addedPackages.add(pkg);
            _logSuccess('  ✓ $pkg added');
          } else {
            _logError('  ✗ $pkg failed to add');
          }
        }
      }
    }

    // ── Inject category comments into pubspec.yaml ─────────────────────
    _logInfo('\nOrganizing pubspec.yaml with category comments...');
    await _injectCategoryComments();

    _logSuccess('\nSetup completed.');
    _printSummary(
      created: created,
      skipped: skipped,
      android: scaffoldAndroid,
      ios: scaffoldIos,
      addedPackages: addedPackages,
      skippedPackages: skippedPackages,
    );

    return 0;
  }

  // ── Package helpers ────────────────────────────────────────────────────

  bool _packageExists(String pubspecContent, String packageName) {
    final pattern = RegExp(
      r'^\s+' + RegExp.escape(packageName) + r'\s*:',
      multiLine: true,
    );
    return pattern.hasMatch(pubspecContent);
  }

  Future<bool> _addPackage(String packageName) async {
    final result = await Process.run(
      'flutter',
      ['pub', 'add', packageName],
      runInShell: true,
    );
    return result.exitCode == 0;
  }

  Future<void> _injectCategoryComments() async {
    final file = File('pubspec.yaml');
    final lines = file.readAsLinesSync();
    final result = <String>[];

    final packageToGroup = <String, String>{};
    for (final group in _packageGroups) {
      for (final pkg in group.packages) {
        packageToGroup[pkg] = group.comment;
      }
    }

    final commentsInserted = <String>{};

    for (final line in lines) {
      final trimmed = line.trimLeft();
      String? matchedPackage;
      for (final pkg in packageToGroup.keys) {
        if (trimmed.startsWith('$pkg:') || trimmed.startsWith('$pkg :')) {
          matchedPackage = pkg;
          break;
        }
      }

      if (matchedPackage != null) {
        final comment = packageToGroup[matchedPackage]!;
        if (!commentsInserted.contains(comment)) {
          final prevLine = result.isNotEmpty ? result.last.trim() : '';
          if (prevLine != comment) {
            if (result.isNotEmpty &&
                result.last.trim().isNotEmpty &&
                result.last.trim() != 'dependencies:') {
              result.add('');
            }
            final indent =
                line.substring(0, line.length - line.trimLeft().length);
            result.add('$indent$comment');
          }
          commentsInserted.add(comment);
        }
      }

      result.add(line);
    }

    await file.writeAsString('${result.join('\n')}\n');
  }

  // ── Directory / file helpers ───────────────────────────────────────────

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

  // ── Summary ────────────────────────────────────────────────────────────

  void _printSummary({
    required List<String> created,
    required List<String> skipped,
    required bool android,
    required bool ios,
    required List<String> addedPackages,
    required List<String> skippedPackages,
  }) {
    stdout.writeln('');
    stdout.writeln(_style('Summary', _Ansi.cyan));
    stdout.writeln(
      'Target platforms: ${android ? 'Android ' : ''}${ios ? 'iOS' : ''}'.trim(),
    );
    stdout.writeln('');

    stdout.writeln(_style('Directories & Files', _Ansi.cyan));
    stdout.writeln('  Created: ${created.length}');
    for (final item in created) {
      stdout.writeln('    + $item');
    }
    stdout.writeln('  Skipped: ${skipped.length}');
    for (final item in skipped) {
      stdout.writeln('    - $item');
    }

    stdout.writeln('');
    stdout.writeln(_style('Packages', _Ansi.cyan));
    stdout.writeln('  Added:   ${addedPackages.length}');
    for (final item in addedPackages) {
      stdout.writeln('    + $item');
    }
    stdout.writeln('  Skipped: ${skippedPackages.length}');
    for (final item in skippedPackages) {
      stdout.writeln('    - $item');
    }
  }

  // ── Logging ────────────────────────────────────────────────────────────

  void _logInfo(String message) => stdout.writeln(_style(message, _Ansi.cyan));
  void _logSuccess(String message) =>
      stdout.writeln(_style(message, _Ansi.green));
  void _logSkip(String message) =>
      stdout.writeln(_style(message, _Ansi.yellow));
  void _logError(String message) =>
      stderr.writeln(_style(message, _Ansi.red));

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
  static const String cyan = '\u001b[36m';
}

class _PackageGroup {
  const _PackageGroup(this.comment, this.packages);
  final String comment;
  final List<String> packages;
}

const List<_PackageGroup> _packageGroups = [
  _PackageGroup('#icon', ['hugeicons']),
  _PackageGroup('#navigation', ['go_router', 'path_provider']),
  _PackageGroup('#toast', ['cherry_toast', 'fluttertoast']),
  _PackageGroup('#env', ['flutter_dotenv']),
  _PackageGroup('#local_storage', ['flutter_secure_storage']),
  _PackageGroup('#network', [
    'dio',
    'talker_dio_logger',
    'retrofit',
    'dio_cache_interceptor',
    'synchronized',
  ]),
  _PackageGroup('#ui', ['flutter_screenutil']),
  _PackageGroup('#app_config', [
    'rename_app',
    'change_app_package_name',
    'flutter_launcher_icons',
    'in_app_update',
    'package_info_plus',
  ]),
  _PackageGroup('#image', [
    'cached_network_image',
    'flutter_cache_manager',
  ]),
  _PackageGroup('#date & time', [
    'intl',
  ]),
  _PackageGroup('#logger', [
    'logger',
  ]),
  _PackageGroup('#utils', [
    'photo_view',
    'image_picker',
    'file_picker',
    'carousel_slider',
    'url_launcher',
    'pinput',
  ]),
  _PackageGroup('#core', [
    'dartz',
    'flutter_bloc',
    'equatable',
    'get_it',
  ]),
];

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
