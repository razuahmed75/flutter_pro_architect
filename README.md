# flutter_pro_architect

`flutter_pro_architect` is a production-ready Dart CLI for generating Clean Architecture + BLoC feature modules in Flutter projects.

## Install

```bash
dart pub global activate flutter_pro_architect
```

## Usage

```bash
flutter_pro_architect create_bloc_user
flutter_pro_architect create_bloc_auth
flutter_pro_architect create_bloc_product
```

Command pattern:

```text
create_bloc_<feature_name>
```

## What it generates

For `create_bloc_user`:

```text
lib/
 └── features/
     └── user/
         ├── data/
         │   ├── datasources/
         │   │   └── user_remote_datasource.dart
         │   ├── models/
         │   │   └── user_model.dart
         │   └── repositories/
         │       └── user_repository_impl.dart
         ├── domain/
         │   ├── entities/
         │   │   └── user_entity.dart
         │   ├── repositories/
         │   │   └── user_repository.dart
         │   └── usecases/
         │       ├── get_users_usecase.dart
         │       └── get_user_by_id_usecase.dart
         │       ├── create_user_usecase.dart
         │       ├── update_user_usecase.dart
         │       ├── patch_user_usecase.dart
         │       └── delete_user_usecase.dart
         ├── presentation/
         │   ├── bloc/
         │   │   ├── user_bloc.dart
         │   │   ├── user_event.dart
         │   │   └── user_state.dart
         │   ├── pages/
         │   │   └── user_page.dart
         │   └── widgets/
         │       └── user_card.dart
         └── user_injection.dart
```

Core is created once and reused:

```text
lib/core/
 ├── usecase/usecase.dart
 └── error/failure.dart
```

## Guarantees

- Clean Architecture boundaries:
  - `Presentation -> UseCase -> Repository -> DataSource`
- BLoC-only presentation layer
- Pure Dart domain layer
- Explicit `Model -> Entity` mapping
- Demo API contracts for `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
- Safe generation (won't overwrite an existing feature)
- snake_case file names + PascalCase classes

## Generated code dependencies

Add these to your Flutter app (the generator does not edit app dependencies automatically):

```yaml
dependencies:
  bloc: ^9.0.0
  flutter_bloc: ^9.0.0
  dartz: ^0.10.1
  equatable: ^2.0.7
  get_it: ^8.0.3
```

## Options

```bash
flutter_pro_architect create_bloc_user --no-color
```
