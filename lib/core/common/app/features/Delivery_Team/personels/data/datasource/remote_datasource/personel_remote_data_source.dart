import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/models/personel_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_role.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class PersonelRemoteDataSource {
  Future<List<PersonelModel>> getPersonels();
  Future<void> setRole(String id, UserRole newRole);
  Future<List<PersonelModel>> loadPersonelsByTripId(String tripId);
  Future<List<PersonelModel>> loadPersonelsByDeliveryTeam(String deliveryTeamId);


  // New functions
  Future<PersonelModel> createPersonel({
    required String name,
    required UserRole role,
    String? deliveryTeamId,
    String? tripId,
  });
  
  Future<bool> deletePersonel(String personelId);
  
  Future<bool> deleteAllPersonels(List<String> personelIds);
  
  Future<PersonelModel> updatePersonel({
    required String personelId,
    String? name,
    UserRole? role,
    String? deliveryTeamId,
    String? tripId,
  });
}

class PersonelRemoteDataSourceImpl implements PersonelRemoteDataSource {
  final PocketBase _pocketBaseClient;

  PersonelRemoteDataSourceImpl({required PocketBase pocketBaseClient})
      : _pocketBaseClient = pocketBaseClient;

  @override
  Future<List<PersonelModel>> getPersonels() async {
    final records = await _pocketBaseClient.collection('personels').getFullList();
    return records.map((record) {
      final data = record.toJson();
      return PersonelModel.fromJson(data);
    }).toList();
  }

  @override
  Future<void> setRole(String id, UserRole newRole) async {
    final roleValue = newRole == UserRole.teamLeader ? 'team_leader' : 'helper';
    await _pocketBaseClient.collection('personels').update(
      id,
      body: {'role': roleValue},
    );
  }

  @override
  Future<List<PersonelModel>> loadPersonelsByTripId(String tripId) async {
    final records = await _pocketBaseClient.collection('personels').getFullList(
      filter: 'trip = "$tripId"',
      expand: 'trip,deliveryTeam',
    );
    
    return records.map((record) => PersonelModel.fromJson(record.toJson())).toList();
  }

  @override
  Future<List<PersonelModel>> loadPersonelsByDeliveryTeam(String deliveryTeamId) async {
    final records = await _pocketBaseClient.collection('personels').getFullList(
      filter: 'deliveryTeam = "$deliveryTeamId"',
      expand: 'trip,deliveryTeam',
    );
    
    return records.map((record) => PersonelModel.fromJson(record.toJson())).toList();
  }
  
 
  @override
  Future<PersonelModel> createPersonel({
    required String name,
    required UserRole role,
    String? deliveryTeamId,
    String? tripId,
  }) async {
    try {
      debugPrint('🔄 Creating new personnel: $name');
      
      // Convert role to string format expected by the API
      final roleValue = role == UserRole.teamLeader ? 'teamLeader' : 'helper';
      
      // Prepare the request body
      final body = {
        'name': name,
        'role': roleValue,
      };
      
      // Add optional fields if provided
      if (deliveryTeamId != null) {
        body['deliveryTeam'] = deliveryTeamId;
      }
      
      if (tripId != null) {
        body['trip'] = tripId;
      }
      
      // Create the record
      final record = await _pocketBaseClient.collection('personels').create(
        body: body,
      );
      
      // Get the created record with expanded relations
      final createdRecord = await _pocketBaseClient.collection('personels').getOne(
        record.id,
        expand: 'trip,deliveryTeam',
      );
      
      debugPrint('✅ Successfully created personnel with ID: ${record.id}');
      return PersonelModel.fromJson(createdRecord.toJson());
    } catch (e) {
      debugPrint('❌ Error creating personnel: $e');
      throw ServerException(
        message: 'Failed to create personnel: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
   @override
  Future<bool> deleteAllPersonels(List<String> personelIds) async {
    try {
      debugPrint('🔄 Deleting multiple personnel: ${personelIds.length} items');
      
      // Use Future.wait to delete all personnel in parallel
      await Future.wait(
        personelIds.map((id) => _pocketBaseClient.collection('personels').delete(id))
      );
      
      debugPrint('✅ Successfully deleted all personnel');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting multiple personnel: $e');
      throw ServerException(
        message: 'Failed to delete multiple personnel: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
   @override
  Future<bool> deletePersonel(String personelId) async {
    try {
      debugPrint('🔄 Deleting personnel: $personelId');
      
      await _pocketBaseClient.collection('personels').delete(personelId);
      
      debugPrint('✅ Successfully deleted personnel');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting personnel: $e');
      throw ServerException(
        message: 'Failed to delete personnel: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  

  @override
  Future<PersonelModel> updatePersonel({
    required String personelId,
    String? name,
    UserRole? role,
    String? deliveryTeamId,
    String? tripId,
  }) async {
    try {
      debugPrint('🔄 Updating personnel: $personelId');
      
      // Prepare the request body with only the fields that need to be updated
      final body = <String, dynamic>{};
      
      if (name != null) {
        body['name'] = name;
      }
      
      if (role != null) {
        body['role'] = role == UserRole.teamLeader ? 'teamLeader' : 'helper';
      }
      
      // For deliveryTeam and trip, we need to handle both setting and removing
      // If the value is an empty string, it will remove the relation
      if (deliveryTeamId != null) {
        body['deliveryTeam'] = deliveryTeamId.isEmpty ? null : deliveryTeamId;
      }
      
      if (tripId != null) {
        body['trip'] = tripId.isEmpty ? null : tripId;
      }
      
      // Update the record
      await _pocketBaseClient.collection('personels').update(
        personelId,
        body: body,
      );
      
      // Get the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient.collection('personels').getOne(
        personelId,
        expand: 'trip,deliveryTeam',
      );
      
      debugPrint('✅ Successfully updated personnel');
      return PersonelModel.fromJson(updatedRecord.toJson());
    } catch (e) {
      debugPrint('❌ Error updating personnel: $e');
      throw ServerException(
        message: 'Failed to update personnel: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
