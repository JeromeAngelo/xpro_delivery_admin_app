import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<AuthEntity> signIn({required String email, required String password}) async {
    try {
      final result = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }



  @override
  ResultFuture<String?> getToken() async {
    try {
      final result = await _remoteDataSource.getToken();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<AuthEntity>> getAllUsers() async {
    try {
      final result = await _remoteDataSource.getAllUsers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<AuthEntity> getUserById(String userId) async {
    try {
      final result = await _remoteDataSource.getUserById(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
  
  @override
ResultFuture<AuthEntity> getCurrentUser() async {
  try {
    final result = await _remoteDataSource.getCurrentUser();
    if (result == null) {
      return Left(ServerFailure(
        message: 'No user is currently logged in',
        statusCode: '401',
      ));
    }
    return Right(result);
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    return Left(ServerFailure(message: e.toString(), statusCode: '500'));
  }
}

}
