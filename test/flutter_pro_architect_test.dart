import 'dart:io';

import 'package:flutter_pro_architect/flutter_pro_architect.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterProArchitectCli', () {
    test('returns usage error when command is missing', () async {
      final cli = FlutterProArchitectCli();
      final code = await cli.run([]);
      expect(code, 64);
    });

    test('creates core and feature files for create_bloc_user', () async {
      final tempDir = await Directory.systemTemp.createTemp('fpa_test_');
      final previous = Directory.current;
      try {
        Directory.current = tempDir;
        await File('pubspec.yaml').writeAsString('name: sample_app\n');

        final cli = FlutterProArchitectCli();
        final code = await cli.run(['create_bloc_user', '--no-color']);

        expect(code, 0);
        expect(File('lib/core/usecase/usecase.dart').existsSync(), isTrue);
        expect(File('lib/core/error/failure.dart').existsSync(), isTrue);
        expect(File('lib/features/user/user_injection.dart').existsSync(), isTrue);
        expect(
          File('lib/features/user/domain/usecases/get_user_by_id_usecase.dart').existsSync(),
          isTrue,
        );
      } finally {
        Directory.current = previous;
        await tempDir.delete(recursive: true);
      }
    });

    test('does not overwrite existing feature directory', () async {
      final tempDir = await Directory.systemTemp.createTemp('fpa_test_');
      final previous = Directory.current;
      try {
        Directory.current = tempDir;
        await File('pubspec.yaml').writeAsString('name: sample_app\n');
        await Directory('lib/features/user').create(recursive: true);

        final cli = FlutterProArchitectCli();
        final code = await cli.run(['create_bloc_user', '--no-color']);

        expect(code, 1);
      } finally {
        Directory.current = previous;
        await tempDir.delete(recursive: true);
      }
    });
  });
}
