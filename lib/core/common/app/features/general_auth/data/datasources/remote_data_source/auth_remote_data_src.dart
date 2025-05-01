import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/model/user_role_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class GeneralUserRemoteDataSource {
  const GeneralUserRemoteDataSource();

  /// Get all users
  Future<List<GeneralUserModel>> getAllUsers();

  /// Create a new user
  Future<GeneralUserModel> createUser(GeneralUserModel user);

  /// Update an existing user
  Future<GeneralUserModel> updateUser(GeneralUserModel user);

  /// Delete a specific user
  Future<bool> deleteUser(String userId);

  /// Delete all users
  Future<bool> deleteAllUsers();
}

class GeneralUserRemoteDataSourceImpl implements GeneralUserRemoteDataSource {
  const GeneralUserRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<List<GeneralUserModel>> getAllUsers() async {
    try {
      debugPrint('🔄 Fetching all users');

      // First, let's examine the structure of a single user record to understand the field names
      try {
        final sampleRecords =
            await _pocketBaseClient.collection('users').getFullList();
        if (sampleRecords.isNotEmpty) {
          final record = sampleRecords.first;
          debugPrint('📋 Sample user record structure:');
          debugPrint('Record ID: ${record.id}');
          debugPrint('Record data keys: ${record.data.keys.join(', ')}');

          // Print all fields in the record to see what's available
          record.data.forEach((key, value) {
            debugPrint('Field: $key = $value');
          });
        }
      } catch (e) {
        debugPrint('⚠️ Error examining sample record: $e');
      }

      // Now fetch all users with explicit fields
      final records = await _pocketBaseClient
          .collection('users')
          .getFullList(expand: 'trip,deliveryTeam,user_role', sort: '-created');

      debugPrint('✅ Retrieved ${records.length} users from API');

      List<GeneralUserModel> users = [];

      for (var record in records) {
        try {
          // Debug the raw record data
          debugPrint('🔍 Processing user record: ${record.id}');
          debugPrint('Raw data keys: ${record.data.keys.join(', ')}');

          // Check for email field with different possible names
          String? email;
          if (record.data.containsKey('email')) {
            email = record.data['email'];
            debugPrint('📧 Found email field: $email');
          } else if (record.data.containsKey('username')) {
            email = record.data['email'];
            debugPrint('📧 Using username as email: $email');
          } else {
            // Try to find any field that might contain email
            for (var key in record.data.keys) {
              final value = record.data[key]?.toString() ?? '';
              if (value.contains('@') && value.contains('.')) {
                email = value;
                debugPrint('📧 Found potential email in field $key: $email');
                break;
              }
            }
          }

          // Create a detailed map with all fields explicitly
          final mappedData = {
            'id': record.id,
            'collectionId': record.collectionId,
            'collectionName': record.collectionName,
            'email': email,
            'name': record.data['name'],
            'profilePic': record.data['profilePic'],
            'tripNumberId': record.data['tripNumberId'],
            'user_role': record.data['user_role'],
            'trip': record.data['trip'],
            'deliveryTeam': record.data['deliveryTeam'],
          };

          // Debug the extracted email
          debugPrint(
            '📧 User ${record.id} mapped email: ${mappedData['email']}',
          );

          // Process expanded relations
          TripModel? tripModel;
          DeliveryTeamModel? deliveryTeamModel;
          UserRoleModel? roleModel;

          // Process trip expand if available
          if (record.expand.containsKey('trip') &&
              record.expand['trip'] != null) {
            tripModel = _processTripExpand(record.expand['trip']);
          }

          // Process delivery team expand if available
          if (record.expand.containsKey('deliveryTeam') &&
              record.expand['deliveryTeam'] != null) {
            deliveryTeamModel = _processDeliveryTeamExpand(
              record.expand['deliveryTeam'],
            );
          }

          // Process user role expand if available
          if (record.expand.containsKey('user_role') &&
              record.expand['user_role'] != null) {
            roleModel = _processRoleExpand(record.expand['user_role']);
          }

          // Create the user model with explicit field mapping
          final userModel = GeneralUserModel(
            id: mappedData['id'] as String?,
            collectionId: mappedData['collectionId'] as String?,
            collectionName: mappedData['collectionName'] as String?,
            email: mappedData['email'] as String?,
            name: mappedData['name'] as String?,
            profilePic: mappedData['profilePic'] as String?,
            tripNumberId: mappedData['tripNumberId'] as String?,
            roleId: mappedData['user_role'] as String?,
            tripId: mappedData['trip'] as String?,
            deliveryTeamId: mappedData['deliveryTeam'] as String?,
            tripModel: tripModel,
            deliveryTeamModel: deliveryTeamModel,
            roleModel: roleModel,
          );

          // Debug the created model
          debugPrint(
            '✅ Created user model for ${userModel.name} with email: ${userModel.email}',
          );

          users.add(userModel);
        } catch (itemError) {
          debugPrint(
            '⚠️ Error processing user record: ${itemError.toString()}',
          );
        }
      }

      debugPrint('✅ Successfully processed ${users.length} users');
      return users;
    } catch (e) {
      debugPrint('❌ Failed to fetch all users: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch all users: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Helper method to process trip expand data
  TripModel? _processTripExpand(dynamic tripData) {
    if (tripData == null) return null;

    try {
      debugPrint(
        '🔄 Processing trip expand data type: ${tripData.runtimeType}',
      );

      if (tripData is RecordModel) {
        return TripModel.fromJson({
          'id': tripData.id,
          'collectionId': tripData.collectionId,
          'collectionName': tripData.collectionName,
          ...tripData.data,
        });
      } else if (tripData is List && tripData.isNotEmpty) {
        final firstTrip = tripData.first;
        if (firstTrip is RecordModel) {
          return TripModel.fromJson({
            'id': firstTrip.id,
            'collectionId': firstTrip.collectionId,
            'collectionName': firstTrip.collectionName,
            ...firstTrip.data,
          });
        }
      } else if (tripData is String) {
        // If it's just a string ID, return a minimal model
        return TripModel(id: tripData);
      }

      debugPrint('⚠️ Unhandled trip data format: ${tripData.runtimeType}');
    } catch (e) {
      debugPrint('❌ Error processing trip expand data: $e');
    }

    return null;
  }

  // Helper method to process delivery team expand data
  DeliveryTeamModel? _processDeliveryTeamExpand(dynamic teamData) {
    if (teamData == null) return null;

    try {
      debugPrint(
        '🔄 Processing delivery team expand data type: ${teamData.runtimeType}',
      );

      if (teamData is RecordModel) {
        return DeliveryTeamModel.fromJson({
          'id': teamData.id,
          'collectionId': teamData.collectionId,
          'collectionName': teamData.collectionName,
          ...teamData.data,
        });
      } else if (teamData is List && teamData.isNotEmpty) {
        final firstTeam = teamData.first;
        if (firstTeam is RecordModel) {
          return DeliveryTeamModel.fromJson({
            'id': firstTeam.id,
            'collectionId': firstTeam.collectionId,
            'collectionName': firstTeam.collectionName,
            ...firstTeam.data,
          });
        }
      } else if (teamData is String) {
        // If it's just a string ID, return a minimal model
        return DeliveryTeamModel(id: teamData);
      }

      debugPrint(
        '⚠️ Unhandled delivery team data format: ${teamData.runtimeType}',
      );
    } catch (e) {
      debugPrint('❌ Error processing delivery team expand data: $e');
    }

    return null;
  }

  // Helper method to process user role expand data
  UserRoleModel? _processRoleExpand(dynamic roleData) {
    if (roleData == null) return null;

    try {
      debugPrint(
        '🔄 Processing user role expand data type: ${roleData.runtimeType}',
      );

      if (roleData is RecordModel) {
        return UserRoleModel.fromJson({
          'id': roleData.id,
          'name': roleData.data['name'],
          'permissions': roleData.data['permissions'],
        });
      } else if (roleData is List && roleData.isNotEmpty) {
        final firstRole = roleData.first;
        if (firstRole is RecordModel) {
          return UserRoleModel.fromJson({
            'id': firstRole.id,
            'name': firstRole.data['name'],
            'permissions': firstRole.data['permissions'],
          });
        }
      } else if (roleData is String) {
        // If it's just a string ID, return a minimal model
        return UserRoleModel(id: roleData);
      }

      debugPrint('⚠️ Unhandled user role data format: ${roleData.runtimeType}');
    } catch (e) {
      debugPrint('❌ Error processing user role expand data: $e');
    }

    return null;
  }

  @override
  Future<GeneralUserModel> createUser(GeneralUserModel user) async {
    try {
      debugPrint('🔄 Creating new user: ${user.email}');

      // Prepare data for creation
      final userData = user.toJson();

      // Remove ID fields that should be generated by the server
      userData.remove('id');
      userData.remove('collectionId');
      userData.remove('collectionName');

      // Ensure password is included for new users
      if (!userData.containsKey('password') ||
          userData['password'] == null ||
          userData['password'].isEmpty) {
        throw const ServerException(
          message: 'Password is required for new users',
          statusCode: '400',
        );
      }

      final record = await _pocketBaseClient
          .collection('users')
          .create(body: userData);

      debugPrint('✅ User created successfully: ${record.id}');

      // Fetch the created record with expanded relations
      return getUserById(record.id);
    } catch (e) {
      debugPrint('❌ Failed to create user: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create user: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<GeneralUserModel> updateUser(GeneralUserModel user) async {
    try {
      debugPrint('🔄 Updating user: ${user.id}');

      if (user.id == null || user.id!.isEmpty) {
        throw const ServerException(
          message: 'Cannot update user: Missing ID',
          statusCode: '400',
        );
      }

      // Prepare data for update
      final userData = user.toJson();

      // Remove fields that shouldn't be updated
      userData.remove('id');
      userData.remove('collectionId');
      userData.remove('collectionName');

      // Remove password if it's empty (to avoid changing it)
      if (userData.containsKey('password') &&
          (userData['password'] == null || userData['password'].isEmpty)) {
        userData.remove('password');
      }

      await _pocketBaseClient
          .collection('users')
          .update(user.id!, body: userData);

      debugPrint('✅ User updated successfully');

      // Fetch the updated record with expanded relations
      return getUserById(user.id!);
    } catch (e) {
      debugPrint('❌ Failed to update user: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update user: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      debugPrint('🔄 Deleting user: $userId');

      // First, check if the user exists
      await _pocketBaseClient.collection('users').getOne(userId);

      // Delete the user
      await _pocketBaseClient.collection('users').delete(userId);

      debugPrint('✅ User deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete user: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete user: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllUsers() async {
    try {
      debugPrint('⚠️ Attempting to delete all users');

      // Get all users
      final records = await _pocketBaseClient.collection('users').getFullList();

      // Delete each user
      for (final record in records) {
        await _pocketBaseClient.collection('users').delete(record.id);
      }

      debugPrint('✅ All users deleted successfully: ${records.length} records');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete all users: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete all users: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Helper method to get a user by ID with expanded relations
  Future<GeneralUserModel> getUserById(String userId) async {
    try {
      final record = await _pocketBaseClient
          .collection('users')
          .getOne(userId, expand: 'trip,deliveryTeam,user_role');

      return _mapRecordToUserModel(record);
    } catch (e) {
      debugPrint('❌ Failed to fetch user by ID: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch user by ID: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Helper method to map a record to a GeneralUserModel
  GeneralUserModel _mapRecordToUserModel(RecordModel record) {
    try {
      // Extract basic user data
      final userData = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'email': record.data['email'],
        'name': record.data['name'],
        'profilePic': record.data['profilePic'],
        'tripNumberId': record.data['tripNumberId'],
        'token': record.data['token'],
      };

      // Extract IDs for relationships
      String? roleId = record.data['user_role'];
      String? tripId = record.data['trip'];
      String? deliveryTeamId = record.data['deliveryTeam'];

      // Create the user model with just the basic data and IDs
      return GeneralUserModel(
        id: userData['id'] as String?,
        collectionId: userData['collectionId'] as String?,
        collectionName: userData['collectionName'] as String?,
        email: userData['email'] as String?,
        name: userData['name'] as String?,
        profilePic: userData['profilePic'] as String?,
        tripNumberId: userData['tripNumberId'] as String?,
        token: userData['token'] as String?,
        roleId: roleId,
        tripId: tripId,
        deliveryTeamId: deliveryTeamId,
      );
    } catch (e) {
      debugPrint('❌ Error mapping record to UserModel: $e');
      throw ServerException(
        message: 'Failed to map record to UserModel: $e',
        statusCode: '500',
      );
    }
  }

  // Helper method to map an expanded record to a map
  // Map<String, dynamic> _mapExpandedRecord(RecordModel record) {
  //   return {
  //     'id': record.id,
  //     'collectionId': record.collectionId,
  //     'collectionName': record.collectionName,
  //     ...Map<String, dynamic>.from(record.data),
  //     'created': record.created,
  //     'updated': record.updated,
  //   };
  // }
}
