// ignore_for_file: unnecessary_null_comparison

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class TripRemoteDatasurce {
  // Get all trip tickets
  Future<List<TripModel>> getAllTripTickets();

  // Create a new trip ticket
  Future<TripModel> createTripTicket(TripModel trip);

  // Search trip tickets by various criteria
  Future<List<TripModel>> searchTripTickets({
    String? tripNumberId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAccepted,
    bool? isEndTrip,
    String? deliveryTeamId,
    String? vehicleId,
    String? personnelId,
  });

  // Get a specific trip ticket by ID
  Future<TripModel> getTripTicketById(String tripId);

  // Update an existing trip ticket
  Future<TripModel> updateTripTicket(TripModel trip);

  // Delete a specific trip ticket
  Future<bool> deleteTripTicket(String tripId);

  // Delete all trip tickets
  Future<bool> deleteAllTripTickets();
}

class TripRemoteDatasurceImpl implements TripRemoteDatasurce {
  const TripRemoteDatasurceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<TripModel>> getAllTripTickets() async {
    try {
      debugPrint('🔄 Fetching all trip tickets');

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            expand:
                'customers,delivery_team,personels,vehicle,checklist,invoices,user',
            sort: '-created',
          );

      debugPrint('✅ Retrieved ${records.length} trip tickets from API');

      // Debug print for each record
      for (var record in records) {
        debugPrint('📄 Trip Record ID: ${record.id}');
        debugPrint('📄 Trip Number ID: ${record.data['tripNumberId']}');
        debugPrint('📄 Time Accepted: ${record.data['timeAccepted']}');
        debugPrint('📄 Time End Trip: ${record.data['timeEndTrip']}');
        debugPrint('📄 User: ${record.expand['user']}');
        debugPrint('📄 Is Accepted: ${record.data['isAccepted']}');
        debugPrint('📄 Is End Trip: ${record.data['isEndTrip']}');
        debugPrint('-----------------------------------');
      }

      return records.map((record) {
        return _mapRecordToTripModel(record);
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch all trip tickets: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch all trip tickets: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<TripModel> createTripTicket(TripModel trip) async {
    try {
      debugPrint('🔄 Creating new trip ticket');

      // Prepare data for creation
      final Map<String, dynamic> tripData = {};
String tripNumberId = trip.tripNumberId ?? 'TRIP-${DateTime.now().millisecondsSinceEpoch}';
      // Set basic fields
      tripData['tripNumberId'] =
          trip.tripNumberId ?? 'TRIP-${DateTime.now().millisecondsSinceEpoch}';
      tripData['created'] = DateTime.now().toIso8601String();
      tripData['updated'] = DateTime.now().toIso8601String();
      tripData['isAccepted'] = false;
      tripData['isEndTrip'] = false;

       // Generate QR code (using trip number as the QR code value)
    // You can customize this to include more information if needed
    tripData['qrCode'] = tripNumberId;
    debugPrint('📄 Generated QR code: ${tripData['qrCode']}');


      // Handle relationship fields - convert objects to IDs for PocketBase

      // Customers - extract IDs for the relationship
      List<String> customerIds = [];
      if (trip.customers.isNotEmpty) {
        customerIds =
            trip.customers
                .map((customer) => customer.id)
                .where((id) => id != null)
                .cast<String>()
                .toList();
        tripData['customers'] = customerIds;
        debugPrint('📄 Setting customers: ${tripData['customers']}');
      }

      // Vehicle - extract IDs for the relationship
      List<String> vehicleIds = [];
      if (trip.vehicle.isNotEmpty) {
        vehicleIds =
            trip.vehicle
                .map((vehicle) => vehicle.id)
                .where((id) => id != null)
                .cast<String>()
                .toList();
        tripData['vehicle'] = vehicleIds;
        debugPrint('📄 Setting vehicle: ${tripData['vehicle']}');
      }

      // Personnel - extract IDs for the relationship
      List<String> personnelIds = [];
      if (trip.personels.isNotEmpty) {
        personnelIds =
            trip.personels
                .map((personel) => personel.id)
                .where((id) => id != null)
                .cast<String>()
                .toList();
        tripData['personels'] = personnelIds;
        debugPrint('📄 Setting personels: ${tripData['personels']}');
      }

      // Checklist - extract IDs for the relationship
      List<String> checklistIds = [];
      if (trip.checklist.isNotEmpty) {
        checklistIds =
            trip.checklist
                .map((item) => item.id)
                .where((id) => id != null)
                .cast<String>()
                .toList();
        tripData['checklist'] = checklistIds;
        debugPrint('📄 Setting checklist: ${tripData['checklist']}');
      }

      // Invoices - extract IDs for the relationship
      List<String> invoiceIds = [];
      if (trip.invoices.isNotEmpty) {
        invoiceIds =
            trip.invoices
                .map((invoice) => invoice.id)
                .where((id) => id != null)
                .cast<String>()
                .toList();
        tripData['invoices'] = invoiceIds;
        debugPrint('📄 Setting invoices: ${tripData['invoices']}');
      }

      debugPrint('📄 Creating trip with data: $tripData');

      // Create the trip record
      final record = await _pocketBaseClient
          .collection('tripticket')
          .create(body: tripData);

      final String tripId = record.id;
      debugPrint('✅ Trip ticket created successfully: $tripId');

      // Now update all related entities to reference this trip

      // Update customers to reference this trip
      await _updateRelatedEntities('customers', customerIds, tripId);

      // Update vehicles to reference this trip
      await _updateRelatedEntities('vehicle', vehicleIds, tripId);

      // Update personnel to reference this trip
      await _updateRelatedEntities('personels', personnelIds, tripId);

      // Update checklists to reference this trip
      await _updateRelatedEntities('checklist', checklistIds, tripId);

      // Update invoices to reference this trip
      await _updateRelatedEntities('invoices', invoiceIds, tripId);

      debugPrint('✅ All related entities updated with trip reference');

      // Fetch the created record with expanded relations
      return getTripTicketById(tripId);
    } catch (e) {
      debugPrint('❌ Failed to create trip ticket: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create trip ticket: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Helper method to update related entities with a reference to the trip
  Future<void> _updateRelatedEntities(
    String collectionName,
    List<String> entityIds,
    String tripId,
  ) async {
    if (entityIds.isEmpty) return;

    debugPrint('🔄 Updating $collectionName to reference trip: $tripId');

    for (final entityId in entityIds) {
      try {
        // Update the entity to reference this trip
        await _pocketBaseClient
            .collection(collectionName)
            .update(entityId, body: {'trip': tripId});

        debugPrint(
          '✅ Updated $collectionName ID: $entityId with trip reference',
        );
      } catch (e) {
        // Log error but continue with other entities
        debugPrint(
          '⚠️ Failed to update $collectionName ID: $entityId - ${e.toString()}',
        );
      }
    }
  }

  @override
  Future<List<TripModel>> searchTripTickets({
    String? tripNumberId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAccepted,
    bool? isEndTrip,
    String? deliveryTeamId,
    String? vehicleId,
    String? personnelId,
  }) async {
    try {
      debugPrint('🔍 Searching for trip tickets with filters');

      List<String> filters = [];

      if (tripNumberId != null) {
        filters.add('tripNumberId ~ "$tripNumberId"');
      }
      if (startDate != null) {
        filters.add('created >= "${startDate.toIso8601String()}"');
      }
      if (endDate != null) {
        filters.add('created <= "${endDate.toIso8601String()}"');
      }
      if (isAccepted != null) {
        filters.add('isAccepted = $isAccepted');
      }
      if (isEndTrip != null) {
        filters.add('isEndTrip = $isEndTrip');
      }
      if (deliveryTeamId != null) {
        filters.add('delivery_team = "$deliveryTeamId"');
      }
      if (vehicleId != null) {
        filters.add('vehicle = "$vehicleId"');
      }
      if (personnelId != null) {
        filters.add('personels ~ "$personnelId"');
      }

      final filterString = filters.join(' && ');
      debugPrint('🔍 Applied filters: $filterString');

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            filter: filterString.isNotEmpty ? filterString : null,
            expand:
                'customers,delivery_team,personels,vehicle,checklist,invoices',
          );

      debugPrint('✅ Found ${records.length} matching trip tickets');

      return records.map((record) {
        return _mapRecordToTripModel(record);
      }).toList();
    } catch (e) {
      debugPrint('❌ Search failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to search trip tickets: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<TripModel> getTripTicketById(String tripId) async {
    try {
      debugPrint('🔄 Fetching trip ticket by ID: $tripId');

      final record = await _pocketBaseClient
          .collection('tripticket')
          .getOne(
            tripId,
            expand:
                'customers,delivery_team,personels,vehicle,checklist,invoices',
          );

      debugPrint('✅ Trip ticket found: ${record.id}');

      return _mapRecordToTripModel(record);
    } catch (e) {
      debugPrint('❌ Failed to fetch trip ticket: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch trip ticket: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<TripModel> updateTripTicket(TripModel trip) async {
    try {
      debugPrint('🔄 Updating trip ticket: ${trip.id}');

      if (trip.id == null || trip.id!.isEmpty) {
        throw const ServerException(
          message: 'Cannot update trip ticket: Missing ID',
          statusCode: '400',
        );
      }

      // Prepare data for update
      final tripData = trip.toJson();

      // Remove fields that shouldn't be updated
      tripData.remove('id');
      tripData.remove('collectionId');
      tripData.remove('collectionName');
      tripData.remove('created');

      // Set update timestamp
      tripData['updated'] = DateTime.now().toIso8601String();

      await _pocketBaseClient
          .collection('tripticket')
          .update(trip.id!, body: tripData);

      debugPrint('✅ Trip ticket updated successfully');

      // Fetch the updated record with expanded relations
      return getTripTicketById(trip.id!);
    } catch (e) {
      debugPrint('❌ Failed to update trip ticket: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update trip ticket: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteTripTicket(String tripId) async {
    try {
      debugPrint('🔄 Deleting trip ticket: $tripId');

      // First, check if the trip exists
      await _pocketBaseClient.collection('tripticket').getOne(tripId);

      // Delete the trip
      await _pocketBaseClient.collection('tripticket').delete(tripId);

      debugPrint('✅ Trip ticket deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete trip ticket: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete trip ticket: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllTripTickets() async {
    try {
      debugPrint('⚠️ Attempting to delete all trip tickets');

      // Get all trip tickets
      final records =
          await _pocketBaseClient.collection('tripticket').getFullList();

      // Delete each trip ticket
      for (final record in records) {
        await _pocketBaseClient.collection('tripticket').delete(record.id);
      }

      debugPrint(
        '✅ All trip tickets deleted successfully: ${records.length} records',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete all trip tickets: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete all trip tickets: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Helper method to map a record to a TripModel
  TripModel _mapRecordToTripModel(RecordModel record) {
    try {
      debugPrint('🔄 Mapping record to TripModel: ${record.id}');

      // Parse dates properly
      DateTime? timeAccepted;
      if (record.data['timeAccepted'] != null) {
        try {
          timeAccepted = DateTime.parse(record.data['timeAccepted']);
          debugPrint('✅ Parsed timeAccepted: $timeAccepted');
        } catch (e) {
          debugPrint('❌ Failed to parse timeAccepted: ${e.toString()}');
        }
      }

      DateTime? timeEndTrip;
      if (record.data['timeEndTrip'] != null) {
        try {
          timeEndTrip = DateTime.parse(record.data['timeEndTrip']);
          debugPrint('✅ Parsed timeEndTrip: $timeEndTrip');
        } catch (e) {
          debugPrint('❌ Failed to parse timeEndTrip: ${e.toString()}');
        }
      }
      // Handle user data
      final userData = record.expand['user'];
      GeneralUserModel? usersModel;

      if (userData != null) {
        debugPrint('✅ Found user data type: ${userData.runtimeType}');

        try {
          if (userData is RecordModel) {
            // Single record case - explicitly cast to RecordModel
            final userRecord = userData as RecordModel;
            usersModel = GeneralUserModel.fromJson({
              'id': userRecord.id,
              'collectionId': userRecord.collectionId,
              'collectionName': userRecord.collectionName,
              ...userRecord.data,
            });
            debugPrint('✅ Processed single RecordModel user');
          } else // List case
          if (userData.isNotEmpty) {
            var firstUser = userData[0];
            usersModel = GeneralUserModel.fromJson({
              'id': firstUser.id,
              'collectionId': firstUser.collectionId,
              'collectionName': firstUser.collectionName,
              ...firstUser.data,
            });
            debugPrint('✅ Processed first user from list');
          } else {
            debugPrint('⚠️ User data list is empty');
          }

          debugPrint('✅ Mapped user result: ${usersModel?.name}');
        } catch (e) {
          debugPrint('❌ Error processing user data: $e');
          // Continue without user data rather than failing the whole mapping
        }
      } else {
        debugPrint('⚠️ No user data found in record');
      }

      final mappedData = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        ...record.data,
        'customers': _mapExpandedList(record.expand['customers']),
        'delivery_team': _mapExpandedItem(record.expand['delivery_team']),
        'personels': _mapExpandedList(record.expand['personels']),
        'vehicle': _mapExpandedList(record.expand['vehicle']),
        'checklist': _mapExpandedList(record.expand['checklist']),
        'invoices': _mapExpandedList(record.expand['invoices']),
        'user': usersModel?.toJson(),
        'created': record.created,
        'updated': record.updated,
        'timeAccepted': timeAccepted?.toIso8601String(),
        'timeEndTrip': timeEndTrip?.toIso8601String(),
        'longitude': record.data['longitude'],
        'latitude': record.data['latitude'],
      };

      return TripModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Error mapping record to TripModel: $e');
      throw ServerException(
        message: 'Failed to map record to TripModel: $e',
        statusCode: '500',
      );
    }
  }

  // Helper method to map expanded list items
  List<Map<String, dynamic>> _mapExpandedList(dynamic records) {
    if (records == null) return [];

    if (records is List) {
      return records.map((record) {
        if (record is RecordModel) {
          return <String, dynamic>{
            'id': record.id,
            'collectionId': record.collectionId,
            'collectionName': record.collectionName,
            ...Map<String, dynamic>.from(record.data),
            'created': record.created,
            'updated': record.updated,
          };
        }
        return <String, dynamic>{};
      }).toList();
    }

    return [];
  }

  // Helper method to map a single expanded item
  Map<String, dynamic>? _mapExpandedItem(dynamic record) {
    if (record == null) return null;

    if (record is List && record.isNotEmpty) {
      final item = record.first;
      if (item is RecordModel) {
        return <String, dynamic>{
          'id': item.id,
          'collectionId': item.collectionId,
          'collectionName': item.collectionName,
          ...Map<String, dynamic>.from(item.data),
          'created': item.created,
          'updated': item.updated,
        };
      }
    } else if (record is RecordModel) {
      return <String, dynamic>{
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        ...Map<String, dynamic>.from(record.data),
        'created': record.created,
        'updated': record.updated,
      };
    }

    return null;
  }
}
