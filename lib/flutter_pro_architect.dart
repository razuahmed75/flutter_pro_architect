/// Public exports for the `flutter_pro_architect` package.
///
/// Use this barrel file to access package APIs without importing internal
/// paths directly.
///
/// Example:
/// ```dart
/// import 'package:flutter_pro_architect/flutter_pro_architect.dart';
///
/// Future<void> main() async {
///   final exitCode = await FlutterProArchitectCli().run(
///     ['create_bloc_user'],
///   );
///   print(exitCode);
/// }
/// ```
library;
export 'src/cli.dart';
export 'src/feature_generator.dart';
export 'src/name_utils.dart';
export 'src/templates.dart';
