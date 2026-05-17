# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.3] - 2026-05-17
### Updated
- Updated issues tracker, homepage and repository links

## [2.1.2] - 2026-05-17
### Fixed
- Updated issues tracker, homepage and repository links

## [2.1.1] - 2026-05-17
### Fixed
- Fixed code warning issue

## [2.1.0] - 2026-05-17
### Added
- Added screenshots in CHANGELOG.md and README.md

## [2.0.0] - 2026-05-17

### Added
- Added a full `Templates` catalog class as a public API to enable custom programmatical exports of boilerplate codes.
- Introduced `setup` executable bootstrap script (`flutter pub run flutter_pro_architect:setup`) to easily bootstrap brand new projects.
- Added platform-specific scaffolding flags (`--android`, `--ios`, `--both`) to target bootstrap operations.
- Added utility string transformation helper functions (`toSnakeCase`, `toPascalCase`) as public APIs.
- Created interactive workbench example app (`example/`) demonstrating all public interfaces of the CLI and generators.

### Changed
- Migrated code generator to standard `src/` modular layout and configured public exports using barrel `lib/flutter_pro_architect.dart`.
- Upgraded command line parsing using the `args` library to support global `--no-color` logs safely.
- Enhanced generated presentation BLoC files to support `flutter_bloc` 8.x + and Dart 3.0 records/patterns.

### Fixed
- Fixed directory structure validation checks to fail gracefully when run outside of the Flutter project root.
- Corrected double-underscore casing bugs in feature name parsing for inputs containing consecutive spaces or hyphens.
- Resolved recursive directory creation errors on Unix systems when path permissions were restrictive.

### Security
- Added input sanitization guards on `create_bloc_<feature>` commands to protect against potential path traversal attacks during file generation.

---

## [1.0.0] - 2024-11-12

### Added
- Initial stable release of `flutter_pro_architect`.
- Production-ready dynamic CLI tool featuring `create_bloc_<feature_name>` code scaffolding.
- Scaffolding templates for Data, Domain, and Presentation layers mapped to clean architecture guidelines.
- Out of the box mapping and setup support for `get_it`, `dartz`, `equatable`, and `flutter_bloc`.
- Collision detection checks to prevent overwriting existing feature code.
- Styled console log messages with ANSI terminal coloring support.
