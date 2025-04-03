import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:desktop_app/core/common/app/features/auth/data/models/auth_model.dart';
import 'package:desktop_app/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> signIn({required String email, required String password});
  Future<void> signOut();
  Future<String?> getToken();
  Future<List<AuthModel>> getAllUsers();
  Future<AuthModel> getUserById(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final PocketBase _pocketBaseClient;

  const AuthRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  @override
  Future<AuthModel> signIn({required String email, required String password}) async {
    try {
      debugPrint('🔐 Attempting sign in for: $email');

      final authData = await _pocketBaseClient
          .collection('admin_users')
          .authWithPassword(email, password);

      if (authData.token.isEmpty) {
        throw const ServerException(
          message: 'Authentication failed',
          statusCode: 'Auth Error',
        );
      }

      _pocketBaseClient.authStore.save(authData.token, authData.record);
      debugPrint('🔑 Auth Token: ${authData.token}');

      final userRecord = await _pocketBaseClient.collection('admin_users').getOne(
        authData.record!.id,
      );

      final mappedData = {
        'id': userRecord.id,
        'collectionId': userRecord.collectionId,
        'collectionName': userRecord.collectionName,
        'email': userRecord.data['email'],
        'name': userRecord.data['name'],
        'profilePic': userRecord.data['profilePic'],
        'role': userRecord.data['role'],
        'isActive': userRecord.data['isActive'] ?? true,
        'lastLogin': DateTime.now().toIso8601String(),
        'permissions': userRecord.data['permissions'],
        'token': authData.token,
      };

      // Update last login time
      await _pocketBaseClient.collection('admin_users').update(
        userRecord.id,
        body: {
          'lastLogin': DateTime.now().toIso8601String(),
        },
      );

      return AuthModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Authentication error: ${e.toString()}');
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      debugPrint('🚪 Signing out user');
      _pocketBaseClient.authStore.clear();
      debugPrint('✅ User signed out successfully');
      return;
    } catch (e) {
      debugPrint('❌ Sign out error: ${e.toString()}');
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }



  @override
  Future<String?> getToken() async {
    try {
      debugPrint('🔑 Retrieving auth token');
      final token = _pocketBaseClient.authStore.token;
      return token.isNotEmpty ? token : null;
    } catch (e) {
      debugPrint('❌ Token retrieval error: ${e.toString()}');
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<List<AuthModel>> getAllUsers() async {
    try {
      debugPrint('👥 Fetching all admin users');
      final records = await _pocketBaseClient.collection('admin_users').getFullList();
      
      List<AuthModel> users = [];
      for (var record in records) {
        users.add(AuthModel.fromJson({
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'email': record.data['email'],
          'name': record.data['name'],
          'profilePic': record.data['profilePic'],
          'role': record.data['role'],
          'isActive': record.data['isActive'] ?? true,
          'lastLogin': record.data['lastLogin'],
          'permissions': record.data['permissions'],
        }));
      }
      
      debugPrint('✅ Retrieved ${users.length} admin users');
      return users;
    } catch (e) {
      debugPrint('❌ Error fetching users: ${e.toString()}');
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<AuthModel> getUserById(String userId) async {
    try {
      debugPrint('🔍 Fetching admin user with ID: $userId');
      final record = await _pocketBaseClient.collection('admin_users').getOne(userId);
      
      final user = AuthModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'email': record.data['email'],
        'name': record.data['name'],
        'profilePic': record.data['profilePic'],
        'role': record.data['role'],
        'isActive': record.data['isActive'] ?? true,
        'lastLogin': record.data['lastLogin'],
        'permissions': record.data['permissions'],
      });
      
      debugPrint('✅ Retrieved user: ${user.name}');
      return user;
    } catch (e) {
      debugPrint('❌ Error fetching user: ${e.toString()}');
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }
}
