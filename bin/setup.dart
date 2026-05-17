import 'dart:io';
import 'package:flutter_pro_architect/flutter_pro_architect.dart';

Future<void> main(List<String> args) async {
  final generator = SetupGenerator();
  exitCode = await generator.run(args);
}
