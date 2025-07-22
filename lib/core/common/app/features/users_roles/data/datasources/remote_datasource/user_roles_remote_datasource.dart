// ignore_for_file: unnecessary_type_check

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/data/model/user_role_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';

abstract class UserRolesRemoteDatasource {
  Future<List<UserRoleModel>> getAllRoles();
}

class UserRolesRemoteDatasourceImpl extends UserRolesRemoteDatasource {
  UserRolesRemoteDatasourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  static const String _authTokenKey = 'auth_token';
  static const String _authUserKey = 'auth_user';

  // Helper method to ensure PocketBase client is authenticated
  Future<void> _ensureAuthenticated() async {
    try {
      // Check if already authenticated
      if (_pocketBaseClient.authStore.isValid) {
        debugPrint('✅ PocketBase client already authenticated');
        return;
      }

      debugPrint('⚠️ PocketBase client not authenticated, attempting to restore from storage');

      // Try to restore authentication from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(_authTokenKey);
      final userDataString = prefs.getString(_authUserKey);

      if (authToken != null && userDataString != null) {
        debugPrint('🔄 Restoring authentication from storage');

        // Restore the auth store with token only
        // The PocketBase client will handle the record validation
        _pocketBaseClient.authStore.save(authToken, null);
        
        debugPrint('✅ Authentication restored from storage');
      } else {
        debugPrint('❌ No stored authentication found');
        throw const ServerException(
          message: 'User not authenticated. Please log in again.',
          statusCode: '401',
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to ensure authentication: ${e.toString()}');
      throw ServerException(
        message: 'Authentication error: ${e.toString()}',
        statusCode: '401',
      );
    }
  }

  @override
  Future<List<UserRoleModel>> getAllRoles() async {
    try {
      debugPrint('🔄 Fetching all user roles');
      
      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();
      
      final result = await _pocketBaseClient
          .collection('userRoles')
          .getFullList(expand: 'permissions', sort: '-created');

      List<UserRoleModel> userRoles = [];

      for (final record in result) {
        // Convert RecordModel to Map<String, dynamic>
        final recordData = record.toJson();

        // Add the id to the map if needed
        recordData['id'] = record.id;

        // Handle expand data if needed
        if (record.expand.isNotEmpty) {
          recordData['expand'] = {};
          record.expand.forEach((key, value) {
            recordData['expand'][key] =
                value
                    .map((item) => item is RecordModel ? item.toJson() : item)
                    .toList();
          });
        }

        userRoles.add(UserRoleModel.fromJson(recordData));
      }

      debugPrint('✅ Successfully retrieved ${userRoles.length} user roles');
      return userRoles;
    } catch (e) {
      debugPrint('❌ Failed to fetch user roles: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all UserRoles: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
