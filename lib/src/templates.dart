/// Template catalog used by the generator to write feature files.
///
/// Every method returns full file content as a string.
///
/// Example:
/// ```dart
/// final content = Templates.coreUseCase();
/// print(content);
/// ```
class Templates {
  /// Builds the shared core use case contract template.
  ///
  /// Returns:
  /// - Dart source content for `lib/core/usecase/usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.coreUseCase();
  /// ```
  static String coreUseCase() => '''
import 'package:dartz/dartz.dart';

import '../error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
''';

  /// Builds the shared core failure contract template.
  ///
  /// Returns:
  /// - Dart source content for `lib/core/error/failure.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.coreFailure();
  /// ```
  static String coreFailure() => '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
''';

  /// Builds a domain entity template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_entity.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.entity(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String entity({required String featureSnake, required String featurePascal}) => '''
import 'package:equatable/equatable.dart';

class ${featurePascal}Entity extends Equatable {
  const ${featurePascal}Entity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, createdAt];
}
''';

  /// Builds a data model template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_model.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.model(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String model({required String featureSnake, required String featurePascal}) => '''
import '../../domain/entities/${featureSnake}_entity.dart';

class ${featurePascal}Model extends ${featurePascal}Entity {
  const ${featurePascal}Model({
    required super.id,
    required super.name,
    required super.createdAt,
  });

  factory ${featurePascal}Model.fromJson(Map<String, dynamic> json) {
    return ${featurePascal}Model(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ${featurePascal}Entity toEntity() {
    return ${featurePascal}Entity(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }
}
''';

  /// Builds an abstract repository template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_repository.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.repository(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String repository({required String featureSnake, required String featurePascal}) => '''
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/${featureSnake}_entity.dart';

abstract class ${featurePascal}Repository {
  Future<Either<Failure, List<${featurePascal}Entity>>> get${featurePascal}s();
  Future<Either<Failure, ${featurePascal}Entity>> get${featurePascal}ById(String id);
  // Future<Either<Failure, ${featurePascal}Entity>> create$featurePascal(${featurePascal}Entity entity);
  // Future<Either<Failure, ${featurePascal}Entity>> update$featurePascal(${featurePascal}Entity entity);
  // Future<Either<Failure, ${featurePascal}Entity>> patch$featurePascal({
  //   required String id,
  //   required Map<String, dynamic> patchData,
  // });
  // Future<Either<Failure, void>> delete$featurePascal(String id);
}
''';

  /// Builds a remote data source template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_remote_datasource.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.remoteDataSource(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String remoteDataSource({required String featureSnake, required String featurePascal}) => '''
import '../models/${featureSnake}_model.dart';

abstract class ${featurePascal}RemoteDataSource {
  Future<List<${featurePascal}Model>> get${featurePascal}s();
  Future<${featurePascal}Model> get${featurePascal}ById(String id);
  // Future<${featurePascal}Model> create$featurePascal(${featurePascal}Model model);
  // Future<${featurePascal}Model> update$featurePascal(${featurePascal}Model model);
  // Future<${featurePascal}Model> patch$featurePascal({
  //   required String id,
  //   required Map<String, dynamic> patchData,
  // });
  // Future<void> delete$featurePascal(String id);
}

class ${featurePascal}RemoteDataSourceImpl implements ${featurePascal}RemoteDataSource {
  const ${featurePascal}RemoteDataSourceImpl();

  @override
  Future<List<${featurePascal}Model>> get${featurePascal}s() async {
    // GET /${featureSnake}s
    throw UnimplementedError('Implement GET /${featureSnake}s');
  }

  @override
  Future<${featurePascal}Model> get${featurePascal}ById(String id) async {
    // GET /${featureSnake}s/:id
    throw UnimplementedError('Implement GET /${featureSnake}s/:id');
  }

  // @override
  // Future<${featurePascal}Model> create$featurePascal(${featurePascal}Model model) async {
  //   // POST /${featureSnake}s
  //   throw UnimplementedError('Implement POST /${featureSnake}s');
  // }

  // @override
  // Future<${featurePascal}Model> update$featurePascal(${featurePascal}Model model) async {
  //   // PUT /${featureSnake}s/:id
  //   throw UnimplementedError('Implement PUT /${featureSnake}s/:id');
  // }

  // @override
  // Future<${featurePascal}Model> patch$featurePascal({
  //   required String id,
  //   required Map<String, dynamic> patchData,
  // }) async {
  //   // PATCH /${featureSnake}s/:id
  //   throw UnimplementedError('Implement PATCH /${featureSnake}s/:id');
  // }

  // @override
  // Future<void> delete$featurePascal(String id) async {
  //   // DELETE /${featureSnake}s/:id
  //   throw UnimplementedError('Implement DELETE /${featureSnake}s/:id');
  // }
}
''';

  /// Builds a repository implementation template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_repository_impl.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.repositoryImpl(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String repositoryImpl({required String featureSnake, required String featurePascal}) => '''
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/${featureSnake}_entity.dart';
import '../../domain/repositories/${featureSnake}_repository.dart';
import '../datasources/${featureSnake}_remote_datasource.dart';

class ${featurePascal}RepositoryImpl implements ${featurePascal}Repository {
  const ${featurePascal}RepositoryImpl(this.remoteDataSource);

  final ${featurePascal}RemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<${featurePascal}Entity>>> get${featurePascal}s() async {
    try {
      final models = await remoteDataSource.get${featurePascal}s();
      final entities = models.map((model) => model.toEntity()).toList(growable: false);
      return Right(entities);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ${featurePascal}Entity>> get${featurePascal}ById(String id) async {
    try {
      final model = await remoteDataSource.get${featurePascal}ById(id);
      return Right(model.toEntity());
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  // @override
  // Future<Either<Failure, ${featurePascal}Entity>> create$featurePascal(${featurePascal}Entity entity) async {
  //   try {
  //     final created = await remoteDataSource.create$featurePascal(
  //       ${featurePascal}Model(
  //         id: entity.id,
  //         name: entity.name,
  //         createdAt: entity.createdAt,
  //       ),
  //     );
  //     return Right(created.toEntity());
  //   } catch (error) {
  //     return Left(ServerFailure(error.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, ${featurePascal}Entity>> update$featurePascal(${featurePascal}Entity entity) async {
  //   try {
  //     final updated = await remoteDataSource.update$featurePascal(
  //       ${featurePascal}Model(
  //         id: entity.id,
  //         name: entity.name,
  //         createdAt: entity.createdAt,
  //       ),
  //     );
  //     return Right(updated.toEntity());
  //   } catch (error) {
  //     return Left(ServerFailure(error.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, ${featurePascal}Entity>> patch$featurePascal({
  //   required String id,
  //   required Map<String, dynamic> patchData,
  // }) async {
  //   try {
  //     final patched = await remoteDataSource.patch$featurePascal(id: id, patchData: patchData);
  //     return Right(patched.toEntity());
  //   } catch (error) {
  //     return Left(ServerFailure(error.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, void>> delete$featurePascal(String id) async {
  //   try {
  //     await remoteDataSource.delete$featurePascal(id);
  //     return const Right(null);
  //   } catch (error) {
  //     return Left(ServerFailure(error.toString()));
  //   }
  // }
}
''';

  /// Builds the `get all` use case template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `get_<feature>s_usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.getItemsUseCase(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String getItemsUseCase({required String featureSnake, required String featurePascal}) => '''
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/${featureSnake}_entity.dart';
import '../repositories/${featureSnake}_repository.dart';

class Get${featurePascal}sUseCase implements UseCase<List<${featurePascal}Entity>, NoParams> {
  const Get${featurePascal}sUseCase(this.repository);

  final ${featurePascal}Repository repository;

  @override
  Future<Either<Failure, List<${featurePascal}Entity>>> call(NoParams params) {
    return repository.get${featurePascal}s();
  }
}
''';

  /// Builds the `get by id` use case template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `get_<feature>_by_id_usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.getItemByIdUseCase(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String getItemByIdUseCase({required String featureSnake, required String featurePascal}) => '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/${featureSnake}_entity.dart';
import '../repositories/${featureSnake}_repository.dart';

class Get${featurePascal}ByIdUseCase implements UseCase<${featurePascal}Entity, Get${featurePascal}Params> {
  const Get${featurePascal}ByIdUseCase(this.repository);

  final ${featurePascal}Repository repository;

  @override
  Future<Either<Failure, ${featurePascal}Entity>> call(Get${featurePascal}Params params) {
    return repository.get${featurePascal}ById(params.id);
  }
}

class Get${featurePascal}Params extends Equatable {
  const Get${featurePascal}Params({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
''';

  /// Builds a commented POST use case demo template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `create_<feature>_usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.createItemUseCase(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String createItemUseCase({required String featureSnake, required String featurePascal}) => '''
// Demo only (commented): POST use case
// import 'package:dartz/dartz.dart';
//
// import '../../../../core/error/failure.dart';
// import '../../../../core/usecase/usecase.dart';
// import '../entities/${featureSnake}_entity.dart';
// import '../repositories/${featureSnake}_repository.dart';
//
// class Create${featurePascal}UseCase implements UseCase<${featurePascal}Entity, Create${featurePascal}Params> {
//   const Create${featurePascal}UseCase(this.repository);
//
//   final ${featurePascal}Repository repository;
//
//   @override
//   Future<Either<Failure, ${featurePascal}Entity>> call(Create${featurePascal}Params params) {
//     return repository.create$featurePascal(params.entity);
//   }
// }
//
// class Create${featurePascal}Params {
//   const Create${featurePascal}Params({required this.entity});
//
//   final ${featurePascal}Entity entity;
// }
''';

  /// Builds a commented PUT use case demo template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `update_<feature>_usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.updateItemUseCase(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String updateItemUseCase({required String featureSnake, required String featurePascal}) => '''
// Demo only (commented): PUT use case
// import 'package:dartz/dartz.dart';
//
// import '../../../../core/error/failure.dart';
// import '../../../../core/usecase/usecase.dart';
// import '../entities/${featureSnake}_entity.dart';
// import '../repositories/${featureSnake}_repository.dart';
//
// class Update${featurePascal}UseCase implements UseCase<${featurePascal}Entity, Update${featurePascal}Params> {
//   const Update${featurePascal}UseCase(this.repository);
//
//   final ${featurePascal}Repository repository;
//
//   @override
//   Future<Either<Failure, ${featurePascal}Entity>> call(Update${featurePascal}Params params) {
//     return repository.update$featurePascal(params.entity);
//   }
// }
//
// class Update${featurePascal}Params {
//   const Update${featurePascal}Params({required this.entity});
//
//   final ${featurePascal}Entity entity;
// }
''';

  /// Builds a commented PATCH use case demo template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `patch_<feature>_usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.patchItemUseCase(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String patchItemUseCase({required String featureSnake, required String featurePascal}) => '''
// Demo only (commented): PATCH use case
// import 'package:dartz/dartz.dart';
//
// import '../../../../core/error/failure.dart';
// import '../../../../core/usecase/usecase.dart';
// import '../entities/${featureSnake}_entity.dart';
// import '../repositories/${featureSnake}_repository.dart';
//
// class Patch${featurePascal}UseCase implements UseCase<${featurePascal}Entity, Patch${featurePascal}Params> {
//   const Patch${featurePascal}UseCase(this.repository);
//
//   final ${featurePascal}Repository repository;
//
//   @override
//   Future<Either<Failure, ${featurePascal}Entity>> call(Patch${featurePascal}Params params) {
//     return repository.patch$featurePascal(id: params.id, patchData: params.patchData);
//   }
// }
//
// class Patch${featurePascal}Params {
//   const Patch${featurePascal}Params({
//     required this.id,
//     required this.patchData,
//   });
//
//   final String id;
//   final Map<String, dynamic> patchData;
// }
''';

  /// Builds a commented DELETE use case demo template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `delete_<feature>_usecase.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.deleteItemUseCase(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String deleteItemUseCase({required String featureSnake, required String featurePascal}) => '''
// Demo only (commented): DELETE use case
// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
//
// import '../../../../core/error/failure.dart';
// import '../../../../core/usecase/usecase.dart';
// import '../repositories/${featureSnake}_repository.dart';
//
// class Delete${featurePascal}UseCase implements UseCase<void, Delete${featurePascal}Params> {
//   const Delete${featurePascal}UseCase(this.repository);
//
//   final ${featurePascal}Repository repository;
//
//   @override
//   Future<Either<Failure, void>> call(Delete${featurePascal}Params params) {
//     return repository.delete$featurePascal(params.id);
//   }
// }
//
// class Delete${featurePascal}Params extends Equatable {
//   const Delete${featurePascal}Params({required this.id});
//
//   final String id;
//
//   @override
//   List<Object?> get props => [id];
// }
''';

  /// Builds a BLoC event template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_event.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.event(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String event({required String featureSnake, required String featurePascal}) => '''
part of '${featureSnake}_bloc.dart';

sealed class ${featurePascal}Event extends Equatable {
  const ${featurePascal}Event();

  @override
  List<Object?> get props => [];
}

final class Load${featurePascal}sRequested extends ${featurePascal}Event {
  const Load${featurePascal}sRequested();
}

final class Load${featurePascal}ByIdRequested extends ${featurePascal}Event {
  const Load${featurePascal}ByIdRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

// final class Create${featurePascal}Requested extends ${featurePascal}Event {
//   const Create${featurePascal}Requested(this.entity);
//
//   final ${featurePascal}Entity entity;
//
//   @override
//   List<Object?> get props => [entity];
// }
//
// final class Update${featurePascal}Requested extends ${featurePascal}Event {
//   const Update${featurePascal}Requested(this.entity);
//
//   final ${featurePascal}Entity entity;
//
//   @override
//   List<Object?> get props => [entity];
// }
//
// final class Patch${featurePascal}Requested extends ${featurePascal}Event {
//   const Patch${featurePascal}Requested({
//     required this.id,
//     required this.patchData,
//   });
//
//   final String id;
//   final Map<String, dynamic> patchData;
//
//   @override
//   List<Object?> get props => [id, patchData];
// }
//
// final class Delete${featurePascal}Requested extends ${featurePascal}Event {
//   const Delete${featurePascal}Requested(this.id);
//
//   final String id;
//
//   @override
//   List<Object?> get props => [id];
// }
''';

  /// Builds a BLoC state template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_state.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.state(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String state({required String featureSnake, required String featurePascal}) => '''
part of '${featureSnake}_bloc.dart';

sealed class ${featurePascal}State extends Equatable {
  const ${featurePascal}State();

  @override
  List<Object?> get props => [];
}

final class ${featurePascal}Initial extends ${featurePascal}State {
  const ${featurePascal}Initial();
}

final class ${featurePascal}Loading extends ${featurePascal}State {
  const ${featurePascal}Loading();
}

final class ${featurePascal}Loaded extends ${featurePascal}State {
  const ${featurePascal}Loaded({
    required this.items,
    this.selected,
    this.message,
  });

  final List<${featurePascal}Entity> items;
  final ${featurePascal}Entity? selected;
  final String? message;

  @override
  List<Object?> get props => [items, selected, message];
}

final class ${featurePascal}Error extends ${featurePascal}State {
  const ${featurePascal}Error(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
''';

  /// Builds a BLoC class template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_bloc.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.bloc(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String bloc({required String featureSnake, required String featurePascal}) => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/${featureSnake}_entity.dart';
import '../../domain/usecases/get_${featureSnake}_by_id_usecase.dart';
import '../../domain/usecases/get_${featureSnake}s_usecase.dart';
// import '../../domain/usecases/create_${featureSnake}_usecase.dart';
// import '../../domain/usecases/delete_${featureSnake}_usecase.dart';
// import '../../domain/usecases/patch_${featureSnake}_usecase.dart';
// import '../../domain/usecases/update_${featureSnake}_usecase.dart';

part '${featureSnake}_event.dart';
part '${featureSnake}_state.dart';

class ${featurePascal}Bloc extends Bloc<${featurePascal}Event, ${featurePascal}State> {
  ${featurePascal}Bloc({
    required Get${featurePascal}sUseCase get${featurePascal}sUseCase,
    required Get${featurePascal}ByIdUseCase get${featurePascal}ByIdUseCase,
    // required Create${featurePascal}UseCase create${featurePascal}UseCase,
    // required Update${featurePascal}UseCase update${featurePascal}UseCase,
    // required Patch${featurePascal}UseCase patch${featurePascal}UseCase,
    // required Delete${featurePascal}UseCase delete${featurePascal}UseCase,
  })  : _get${featurePascal}sUseCase = get${featurePascal}sUseCase,
        _get${featurePascal}ByIdUseCase = get${featurePascal}ByIdUseCase,
        // _create${featurePascal}UseCase = create${featurePascal}UseCase,
        // _update${featurePascal}UseCase = update${featurePascal}UseCase,
        // _patch${featurePascal}UseCase = patch${featurePascal}UseCase,
        // _delete${featurePascal}UseCase = delete${featurePascal}UseCase,
        super(const ${featurePascal}Initial()) {
    on<Load${featurePascal}sRequested>(_onLoad${featurePascal}sRequested);
    on<Load${featurePascal}ByIdRequested>(_onLoad${featurePascal}ByIdRequested);
    // on<Create${featurePascal}Requested>(_onCreate${featurePascal}Requested);
    // on<Update${featurePascal}Requested>(_onUpdate${featurePascal}Requested);
    // on<Patch${featurePascal}Requested>(_onPatch${featurePascal}Requested);
    // on<Delete${featurePascal}Requested>(_onDelete${featurePascal}Requested);
  }

  final Get${featurePascal}sUseCase _get${featurePascal}sUseCase;
  final Get${featurePascal}ByIdUseCase _get${featurePascal}ByIdUseCase;
  // final Create${featurePascal}UseCase _create${featurePascal}UseCase;
  // final Update${featurePascal}UseCase _update${featurePascal}UseCase;
  // final Patch${featurePascal}UseCase _patch${featurePascal}UseCase;
  // final Delete${featurePascal}UseCase _delete${featurePascal}UseCase;

  Future<void> _onLoad${featurePascal}sRequested(
    Load${featurePascal}sRequested event,
    Emitter<${featurePascal}State> emit,
  ) async {
    emit(const ${featurePascal}Loading());
    final result = await _get${featurePascal}sUseCase(const NoParams());
    result.fold(
      (failure) => emit(${featurePascal}Error(failure.message)),
      (items) => emit(${featurePascal}Loaded(items: items)),
    );
  }

  Future<void> _onLoad${featurePascal}ByIdRequested(
    Load${featurePascal}ByIdRequested event,
    Emitter<${featurePascal}State> emit,
  ) async {
    emit(const ${featurePascal}Loading());
    final result = await _get${featurePascal}ByIdUseCase(Get${featurePascal}Params(id: event.id));
    result.fold(
      (failure) => emit(${featurePascal}Error(failure.message)),
      (item) => emit(${featurePascal}Loaded(items: const [], selected: item)),
    );
  }

  // Future<void> _onCreate${featurePascal}Requested(
  //   Create${featurePascal}Requested event,
  //   Emitter<${featurePascal}State> emit,
  // ) async {
  //   emit(const ${featurePascal}Loading());
  //   final result = await _create${featurePascal}UseCase(Create${featurePascal}Params(entity: event.entity));
  //   result.fold(
  //     (failure) => emit(${featurePascal}Error(failure.message)),
  //     (item) => emit(${featurePascal}Loaded(items: const [], selected: item, message: '$featurePascal created')),
  //   );
  // }
  //
  // Future<void> _onUpdate${featurePascal}Requested(
  //   Update${featurePascal}Requested event,
  //   Emitter<${featurePascal}State> emit,
  // ) async {
  //   emit(const ${featurePascal}Loading());
  //   final result = await _update${featurePascal}UseCase(Update${featurePascal}Params(entity: event.entity));
  //   result.fold(
  //     (failure) => emit(${featurePascal}Error(failure.message)),
  //     (item) => emit(${featurePascal}Loaded(items: const [], selected: item, message: '$featurePascal updated')),
  //   );
  // }
  //
  // Future<void> _onPatch${featurePascal}Requested(
  //   Patch${featurePascal}Requested event,
  //   Emitter<${featurePascal}State> emit,
  // ) async {
  //   emit(const ${featurePascal}Loading());
  //   final result = await _patch${featurePascal}UseCase(
  //     Patch${featurePascal}Params(id: event.id, patchData: event.patchData),
  //   );
  //   result.fold(
  //     (failure) => emit(${featurePascal}Error(failure.message)),
  //     (item) => emit(${featurePascal}Loaded(items: const [], selected: item, message: '$featurePascal patched')),
  //   );
  // }
  //
  // Future<void> _onDelete${featurePascal}Requested(
  //   Delete${featurePascal}Requested event,
  //   Emitter<${featurePascal}State> emit,
  // ) async {
  //   emit(const ${featurePascal}Loading());
  //   final result = await _delete${featurePascal}UseCase(Delete${featurePascal}Params(id: event.id));
  //   result.fold(
  //     (failure) => emit(${featurePascal}Error(failure.message)),
  //     (_) => emit(${featurePascal}Loaded(items: const [], message: '$featurePascal deleted')),
  //   );
  // }
}
''';

  /// Builds a sample Flutter page template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_page.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.page(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String page({required String featureSnake, required String featurePascal}) => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/${featureSnake}_bloc.dart';
import '../widgets/${featureSnake}_card.dart';

class ${featurePascal}Page extends StatelessWidget {
  const ${featurePascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$featurePascal')),
      body: BlocBuilder<${featurePascal}Bloc, ${featurePascal}State>(
        builder: (context, state) {
          if (state is ${featurePascal}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ${featurePascal}Error) {
            return Center(child: Text(state.message));
          }
          if (state is ${featurePascal}Loaded) {
            if (state.items.isEmpty && state.selected == null) {
              return Center(child: Text(state.message ?? 'No data available'));
            }
            if (state.selected != null) {
              return Center(child: ${featurePascal}Card(entity: state.selected!));
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) => ${featurePascal}Card(entity: state.items[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
''';

  /// Builds a sample widget card template for a feature.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_card.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.card(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String card({required String featureSnake, required String featurePascal}) => '''
import 'package:flutter/material.dart';

import '../../domain/entities/${featureSnake}_entity.dart';

class ${featurePascal}Card extends StatelessWidget {
  const ${featurePascal}Card({
    required this.entity,
    super.key,
  });

  final ${featurePascal}Entity entity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(entity.name),
        subtitle: Text('ID: \${entity.id}'),
        trailing: Text(entity.createdAt.toIso8601String()),
      ),
    );
  }
}
''';

  /// Builds feature-level dependency registration template.
  ///
  /// Parameters:
  /// - [featureSnake]: Feature name in `snake_case`.
  /// - [featurePascal]: Feature name in `PascalCase`.
  ///
  /// Returns:
  /// - Dart source content for `<feature>_injection.dart`.
  ///
  /// Example:
  /// ```dart
  /// final text = Templates.injection(
  ///   featureSnake: 'user',
  ///   featurePascal: 'User',
  /// );
  /// ```
  static String injection({required String featureSnake, required String featurePascal}) => '''
import 'package:get_it/get_it.dart';

import 'data/datasources/${featureSnake}_remote_datasource.dart';
import 'data/repositories/${featureSnake}_repository_impl.dart';
import 'domain/repositories/${featureSnake}_repository.dart';
import 'domain/usecases/get_${featureSnake}_by_id_usecase.dart';
import 'domain/usecases/get_${featureSnake}s_usecase.dart';
// import 'domain/usecases/create_${featureSnake}_usecase.dart';
// import 'domain/usecases/delete_${featureSnake}_usecase.dart';
// import 'domain/usecases/patch_${featureSnake}_usecase.dart';
// import 'domain/usecases/update_${featureSnake}_usecase.dart';
import 'presentation/bloc/${featureSnake}_bloc.dart';

void register${featurePascal}Dependencies(GetIt sl) {
  sl
    ..registerFactory(
      () => ${featurePascal}Bloc(
        get${featurePascal}sUseCase: sl(),
        get${featurePascal}ByIdUseCase: sl(),
        // create${featurePascal}UseCase: sl(),
        // update${featurePascal}UseCase: sl(),
        // patch${featurePascal}UseCase: sl(),
        // delete${featurePascal}UseCase: sl(),
      ),
    )
    ..registerLazySingleton(() => Get${featurePascal}sUseCase(sl()))
    ..registerLazySingleton(() => Get${featurePascal}ByIdUseCase(sl()))
    // ..registerLazySingleton(() => Create${featurePascal}UseCase(sl()))
    // ..registerLazySingleton(() => Update${featurePascal}UseCase(sl()))
    // ..registerLazySingleton(() => Patch${featurePascal}UseCase(sl()))
    // ..registerLazySingleton(() => Delete${featurePascal}UseCase(sl()))
    ..registerLazySingleton<${featurePascal}Repository>(
      () => ${featurePascal}RepositoryImpl(sl()),
    )
    ..registerLazySingleton<${featurePascal}RemoteDataSource>(
      ${featurePascal}RemoteDataSourceImpl.new,
    );
}
''';
}
