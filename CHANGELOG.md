## 1.0.0

- Initial stable release of `flutter_pro_architect`.
- Added dynamic `create_bloc_<feature_name>` command support.
- Generates production-ready Clean Architecture + BLoC feature module scaffolding.
- Ensures shared core layer (`usecase.dart`, `failure.dart`) exists once and is reused.
- Prevents overwriting existing feature modules.
- Added command logs with optional ANSI color output.
