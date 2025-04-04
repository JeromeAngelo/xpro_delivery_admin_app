import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desktop_app/core/common/app/features/auth/data/models/auth_model.dart';
import 'package:desktop_app/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> signIn({required String email, required String password});
  Future<void> signOut();
  Future<String?> getToken();
  Future<List<AuthModel>> getAllUsers();
  Future<AuthModel> getUserById(String userId);
  Future<AuthModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final PocketBase _pocketBaseClient;
  static const String _authTokenKey = 'auth_token';
  static const String _authUserKey = 'auth_user';

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

      // Save auth data to shared preferences
      await _saveAuthDataToPrefs(authData.token, mappedData);

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
      
      // Clear saved auth data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_authUserKey);
      
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
      
      // First check if token is in memory
      String token = _pocketBaseClient.authStore.token;
      
      // If not in memory, try to get from shared preferences
      if (token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_authTokenKey) ?? '';
        
        // If found in prefs, restore the auth state
        if (token.isNotEmpty) {
          final userJson = prefs.getString(_authUserKey);
          if (userJson != null) {
            final userData = jsonDecode(userJson);
            final record = RecordModel.fromJson(userData);
            _pocketBaseClient.authStore.save(token, record);
            debugPrint('✅ Restored auth state from preferences');
          }
        }
      }
      
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

  @override
  Future<AuthModel?> getCurrentUser() async {
    try {
      // Check if we have a token
      final token = await getToken();
      if (token == null) {
        debugPrint('❌ No auth token found, user is not logged in');
        return null;
      }
      
      // Get the current user from PocketBase auth store
      final record = _pocketBaseClient.authStore.model;
      if (record == null) {
        debugPrint('❌ No user record found in auth store');
        return null;
      }
      
      // Get full user details
      return getUserById(record.id);
    } catch (e) {
      debugPrint('❌ Error getting current user: ${e.toString()}');
      return null;
    }
  }

  // Helper method to save auth data to shared preferences
  Future<void> _saveAuthDataToPrefs(String token, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, token);
      
      // Create a record model from user data
      final recordData = {
        'id': userData['id'],
        'collectionId': userData['collectionId'],
        'collectionName': userData['collectionName'],
        'data': {
          'email': userData['email'],
          'name': userData['name'],
          'profilePic': userData['profilePic'],
          'role': userData['role'],
          'isActive': userData['isActive'],
          'lastLogin': userData['lastLogin'],
          'permissions': userData['permissions'],
        }
      };
      
      await prefs.setString(_authUserKey, jsonEncode(recordData));
      debugPrint('✅ Auth data saved to preferences');
    } catch (e) {
      debugPrint('❌ Error saving auth data to preferences: ${e.toString()}');
    }
  }
}
