import 'package:dartz/dartz.dart';
import 'package:desktop_app/core/common/app/features/general_auth/data/datasources/remote_data_source/auth_remote_data_src.dart';
import 'package:desktop_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:desktop_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:desktop_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:desktop_app/core/errors/failures.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';

class GeneralUserRepoImpl implements GeneralUserRepo {
  final GeneralUserRemoteDataSource _remoteDataSource;

  const GeneralUserRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<List<GeneralUserEntity>> getAllUsers() async {
    try {
      debugPrint('🔄 REPO: Fetching all users');
      final remoteUsers = await _remoteDataSource.getAllUsers();
      debugPrint('✅ REPO: Successfully retrieved ${remoteUsers.length} users');
      return Right(remoteUsers);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<GeneralUserEntity> createUser(GeneralUserEntity user) async {
    try {
      debugPrint('🔄 REPO: Creating new user');
      
      // Convert entity to model
      final userModel = user as GeneralUserModel;
      
      final createdUser = await _remoteDataSource.createUser(userModel);
      debugPrint('✅ REPO: User created successfully: ${createdUser.id}');
      return Right(createdUser);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<GeneralUserEntity> updateUser(GeneralUserEntity user) async {
    try {
      debugPrint('🔄 REPO: Updating user: ${user.id}');
      
      // Convert entity to model
      final userModel = user as GeneralUserModel;
      
      final updatedUser = await _remoteDataSource.updateUser(userModel);
      debugPrint('✅ REPO: User updated successfully');
      return Right(updatedUser);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteUser(String userId) async {
    try {
      debugPrint('🔄 REPO: Deleting user: $userId');
      final result = await _remoteDataSource.deleteUser(userId);
      debugPrint('✅ REPO: User deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllUsers() async {
    try {
      debugPrint('🔄 REPO: Deleting all users');
      final result = await _remoteDataSource.deleteAllUsers();
      debugPrint('✅ REPO: All users deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
