import 'package:desktop_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';

abstract class AuthRepo {

  
// Authentication
  ResultFuture<AuthEntity> signIn({required String email, required String password});
  ResultFuture<void> signOut();
  ResultFuture<String?> getToken();
  ResultFuture<List<AuthEntity>> getAllUsers();
  ResultFuture<AuthEntity> getUserById(String userId);
   // System settings
// Add this method to your AuthRepo interface
 ResultFuture<AuthEntity> getCurrentUser();

}