import 'dart:io';

import 'package:flutter_pro_architect/flutter_pro_architect.dart';

Future<void> main(List<String> arguments) async {
  final code = await FlutterProArchitectCli().run(arguments);
  exit(code);
}
