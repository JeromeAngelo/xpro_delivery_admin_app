import 'package:desktop_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';

abstract class GeneralUserRepo {
  const GeneralUserRepo();

  /// Get all users
  ResultFuture<List<GeneralUserEntity>> getAllUsers();
  
  /// Create a new user
  ResultFuture<GeneralUserEntity> createUser(GeneralUserEntity user);
  
  /// Update an existing user
  ResultFuture<GeneralUserEntity> updateUser(GeneralUserEntity user);
  
  /// Delete a specific user
  ResultFuture<bool> deleteUser(String userId);
  
  /// Delete all users
  ResultFuture<bool> deleteAllUsers();
}
