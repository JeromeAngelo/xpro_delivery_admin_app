// ignore_for_file: unnecessary_null_comparison

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/data/model/delivery_data_model.dart'
    show DeliveryDataModel;
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/data/model/collection_model.dart'
    as collection;
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/data/model/cancelled_invoice_model.dart';
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

  // NEW: Filter by date range
  Future<List<TripModel>> filterTripsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  // NEW: Filter by user
  Future<List<TripModel>> filterTripsByUser({required String userId});
}

class TripRemoteDatasurceImpl implements TripRemoteDatasurce {
  const TripRemoteDatasurceImpl({required PocketBase pocketBaseClient})
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

      debugPrint(
        '⚠️ PocketBase client not authenticated, attempting to restore from storage',
      );

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
  Future<List<TripModel>> filterTripsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('🔍 Filtering trips by date range');

      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();
      debugPrint('📅 Start Date: ${startDate.toIso8601String()}');
      debugPrint('📅 End Date: ${endDate.toIso8601String()}');

      // Build filter string for date range using timeAccepted and timeEndTrip
      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();

      final filterString =
          '(timeAccepted >= "$startDateStr" && timeAccepted <= "$endDateStr") || (timeEndTrip >= "$startDateStr" && timeEndTrip <= "$endDateStr")';

      debugPrint('🔍 Applied filter: $filterString');

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            filter: filterString,
            expand:
                'customers,deliveryTeam,personels,vehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
            sort: '-created',
          );

      debugPrint('✅ Found ${records.length} trips in date range');

      return records.map((record) {
        return _mapRecordToTripModel(record);
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to filter trips by date range: ${e.toString()}');
      throw ServerException(
        message: 'Failed to filter trips by date range: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<TripModel>> filterTripsByUser({required String userId}) async {
    try {
      debugPrint('🔍 Filtering trips by user ID: $userId');

      final filterString = 'user = "$userId"';
      debugPrint('🔍 Applied filter: $filterString');

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            filter: filterString,
            expand:
                'customers,deliveryTeam,personels,vehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
            sort: '-created',
          );

      debugPrint('✅ Found ${records.length} trips for user: $userId');

      // Debug print user information for each trip
      for (var record in records) {
        final userData = record.expand['user'];
        if (userData != null) {
          debugPrint('📄 Trip: ${record.data['tripNumberId']} ');
        }
      }

      return records.map((record) {
        return _mapRecordToTripModel(record);
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to filter trips by user: ${e.toString()}');
      throw ServerException(
        message: 'Failed to filter trips by user: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<TripModel>> getAllTripTickets() async {
    try {
      debugPrint('🔄 Fetching all trip tickets');

      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            expand:
                'customers,deliveryTeam,personels,vehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
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
      String tripNumberId =
          trip.tripNumberId ?? 'TRIP-${DateTime.now().millisecondsSinceEpoch}';

      // Set basic fields
      tripData['tripNumberId'] = tripNumberId;
      tripData['created'] = DateTime.now().toIso8601String();
      tripData['updated'] = DateTime.now().toIso8601String();
      tripData['isAccepted'] = false;
      tripData['isEndTrip'] = false;

      // Generate QR code (using trip number as the QR code value)
      tripData['qrCode'] = tripNumberId;
      debugPrint('📄 Generated QR code: ${tripData['qrCode']}');

      // Handle vehicle - Set the deliveryVehicle field in tripticket
      if (trip.vehicle != null && trip.vehicle!.id != null) {
        tripData['deliveryVehicle'] = trip.vehicle!.id;
        debugPrint(
          '📄 Setting deliveryVehicle field: ${tripData['deliveryVehicle']}',
        );

        // Calculate volume and weight capacity rates
        await _calculateAndSetCapacityRates(
          trip.vehicle! as DeliveryVehicleModel,
          tripData,
        );
      } else {
        // Set default values if no vehicle is provided
        tripData['volumeRate'] = 0;
        tripData['capacityRate'] = 0;
        tripData['averageFillRate'] = 0;
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

      debugPrint('📄 Creating trip with data: $tripData');

      // Create the trip record
      final tripRecord = await _pocketBaseClient
          .collection('tripticket')
          .create(body: tripData);

      final String tripId = tripRecord.id;
      debugPrint('✅ Trip ticket created successfully: $tripId');

      // Find deliveryData items with null trip field and assign this trip
      debugPrint('🔄 Finding deliveryData items with null trip field');
      final deliveryDataRecords = await _pocketBaseClient
          .collection('deliveryData')
          .getFullList(filter: 'trip = null');

      List<String> deliveryDataIds = [];

      // Get the "Pending" status from delivery_status_choices
      debugPrint('🔄 Fetching Pending status from delivery_status_choices');
      final pendingStatus = await _pocketBaseClient
          .collection('deliveryStatusChoices')
          .getFirstListItem('title = "Pending"');

      debugPrint('✅ Found Pending status: ${pendingStatus.id}');

      // Update each deliveryData item to reference this trip
      for (final dataRecord in deliveryDataRecords) {
        // First update the deliveryData to reference this trip
        await _pocketBaseClient
            .collection('deliveryData')
            .update(dataRecord.id, body: {'trip': tripId, 'hasTrip': true});

        deliveryDataIds.add(dataRecord.id);
        debugPrint(
          '✅ Updated deliveryData item ${dataRecord.id} with trip reference',
        );

        // Create a delivery_update record with Pending status
        debugPrint(
          '🔄 Creating delivery_update with Pending status for deliveryData: ${dataRecord.id}',
        );
        final deliveryUpdateRecord = await _pocketBaseClient
            .collection('deliveryUpdate')
            .create(
              body: {
                'deliveryData': dataRecord.id,
                'status': pendingStatus.id,
                'title': pendingStatus.data['title'],
                'subtitle': pendingStatus.data['subtitle'],
                'created': DateTime.now().toIso8601String(),
                'time': DateTime.now().toIso8601String(),
                'isAssigned': true,
              },
            );

        // Update the deliveryData to include this delivery update
        await _pocketBaseClient
            .collection('deliveryData')
            .update(
              dataRecord.id,
              body: {
                'deliveryUpdates+': [deliveryUpdateRecord.id],
              },
            );

        debugPrint(
          '✅ Created and linked delivery_update record: ${deliveryUpdateRecord.id}',
        );
      }

      // Update the trip with the deliveryData references
      if (deliveryDataIds.isNotEmpty) {
        await _pocketBaseClient
            .collection('tripticket')
            .update(tripId, body: {'deliveryData': deliveryDataIds});

        debugPrint(
          '✅ Updated trip with ${deliveryDataIds.length} deliveryData references',
        );
      }

      // Update personnel to reference this trip and set isAssigned to true
      await _updatePersonnelWithTrip(personnelIds, tripId);

      // Update checklists to reference this trip
      await _updateRelatedEntities('checklist', checklistIds, tripId);

      debugPrint('✅ All related entities updated with trip reference');

      // Verify that the vehicle was properly set in the trip
      final updatedTrip = await _pocketBaseClient
          .collection('tripticket')
          .getOne(tripId);

      if (updatedTrip.data['deliveryVehicle'] != null) {
        debugPrint(
          '✅ Vehicle successfully set in trip: ${updatedTrip.data['deliveryVehicle']}',
        );
      } else if (trip.vehicle != null && trip.vehicle!.id != null) {
        debugPrint('⚠️ Vehicle not set in trip, attempting to update');
        await _pocketBaseClient
            .collection('tripticket')
            .update(tripId, body: {'deliveryVehicle': trip.vehicle!.id});
        debugPrint('✅ Vehicle updated in trip: ${trip.vehicle!.id}');
      }

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

  // Helper method to calculate and set capacity rates
  Future<void> _calculateAndSetCapacityRates(
    DeliveryVehicleModel vehicle,
    Map<String, dynamic> tripData,
  ) async {
    try {
      debugPrint('🔄 Calculating vehicle capacity rates');

      // Get all unassigned delivery data
      final deliveryDataRecords = await _pocketBaseClient
          .collection('deliveryData')
          .getFullList(filter: 'hasTrip = false');

      double totalWeight = 0;
      double totalVolume = 0;

      // Calculate total weight and volume from all deliveries
      for (final record in deliveryDataRecords) {
        // Check if the record has an invoice field
        if (record.data['invoice'] != null) {
          // Get the invoice details
          final invoiceId = record.data['invoice'];
          final invoice = await _pocketBaseClient
              .collection('invoice')
              .getOne(invoiceId);

          // Add weight and volume
          totalWeight +=
              double.tryParse(invoice.data['weight']?.toString() ?? '0') ?? 0;
          totalVolume +=
              double.tryParse(invoice.data['volume']?.toString() ?? '0') ?? 0;
        }
      }

      // Calculate percentages (handle division by zero)
      final weightCapacity = vehicle.weightCapacity ?? 0;
      final volumeCapacity = vehicle.volumeCapacity ?? 0;

      final weightPercentage =
          weightCapacity > 0 ? (totalWeight / weightCapacity) * 100 : 0;

      final volumePercentage =
          volumeCapacity > 0 ? (totalVolume / volumeCapacity) * 100 : 0;

      // Set the calculated rates in the trip data
      tripData['capacityRate'] = weightPercentage.round();
      tripData['volumeRate'] = volumePercentage.round();

      // Calculate and set the average fill rate
      final averageFillRate = (weightPercentage + volumePercentage) / 2;
      tripData['averageFillRate'] = averageFillRate.round();

      debugPrint('📊 Calculated capacity rate: ${tripData['capacityRate']}%');
      debugPrint('📊 Calculated volume rate: ${tripData['volumeRate']}%');
      debugPrint(
        '📊 Calculated average fill rate: ${tripData['averageFillRate']}%',
      );
    } catch (e) {
      debugPrint('⚠️ Error calculating capacity rates: ${e.toString()}');
      // Set default values in case of error
      tripData['volumeRate'] = 0;
      tripData['capacityRate'] = 0;
      tripData['averageFillRate'] = 0;
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

  // Helper method to update personnel with trip reference and set isAssigned to true
  Future<void> _updatePersonnelWithTrip(
    List<String> personnelIds,
    String tripId,
  ) async {
    if (personnelIds.isEmpty) return;

    debugPrint(
      '🔄 Updating personnel to reference trip and set isAssigned: $tripId',
    );

    for (final personnelId in personnelIds) {
      try {
        // Update the personnel to reference this trip and set isAssigned to true
        await _pocketBaseClient
            .collection('personels')
            .update(personnelId, body: {'trip': tripId, 'isAssigned': true});

        debugPrint(
          '✅ Updated personnel ID: $personnelId with trip reference and isAssigned: true',
        );
      } catch (e) {
        // Log error but continue with other personnel
        debugPrint(
          '⚠️ Failed to update personnel ID: $personnelId - ${e.toString()}',
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
        filters.add('deliveryTeam = "$deliveryTeamId"');
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
                'customers,deliveryTeam,personels,vehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection',
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
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
          );

      debugPrint('✅ Trip ticket found: ${record.id}');
      debugPrint('📊 Available expand fields: ${record.expand.keys.toList()}');
      debugPrint('📊 Available data fields: ${record.data.keys.toList()}');
      debugPrint(
        '📊 DeliveryCollection data: ${record.expand['deliveryCollection']}',
      );
      debugPrint(
        '📊 DeliveryCollection type: ${record.expand['deliveryCollection']?.runtimeType}',
      );
      debugPrint(
        '📊 Raw record data contains deliveryCollection: ${record.data.containsKey('deliveryCollection')}',
      );
      if (record.data.containsKey('deliveryCollection')) {
        debugPrint(
          '📊 Raw deliveryCollection value: ${record.data['deliveryCollection']}',
        );
      }

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

      // Handle delivery vehicle - Updated to use single DeliveryVehicleModel
      final vehicleData = record.expand['deliveryVehicle'];
      DeliveryVehicleModel? vehicleModel;

      if (vehicleData != null) {
        debugPrint('✅ Found vehicle data type: ${vehicleData.runtimeType}');

        try {
          if (vehicleData.isNotEmpty) {
            var firstVehicle = vehicleData[0];
            vehicleModel = DeliveryVehicleModel.fromJson({
              'id': firstVehicle.id,
              'collectionId': firstVehicle.collectionId,
              'collectionName': firstVehicle.collectionName,
              ...firstVehicle.data,
            });
            debugPrint('✅ Processed first vehicle from list');
          } else {
            debugPrint('⚠️ Vehicle data format not recognized');
          }
        } catch (e) {
          debugPrint('❌ Error processing vehicle data: $e');
        }
      } else {
        debugPrint('⚠️ No vehicle data found in record');
      }

      // Handle delivery data - New relationship
      final deliveryDataList = record.expand['deliveryData'];
      List<DeliveryDataModel> deliveryDataModels = [];

      if (deliveryDataList != null && deliveryDataList.isNotEmpty) {
        debugPrint('✅ Found delivery data: ${deliveryDataList.runtimeType}');

        try {
          for (var dataItem in deliveryDataList) {
            deliveryDataModels.add(
              DeliveryDataModel.fromJson({
                'id': dataItem.id,
                'collectionId': dataItem.collectionId,
                'collectionName': dataItem.collectionName,
                ...dataItem.data,
              }),
            );
          }
          debugPrint(
            '✅ Processed ${deliveryDataModels.length} delivery data items',
          );
        } catch (e) {
          debugPrint('❌ Error processing delivery data: $e');
        }
      } else {
        // Check if raw data has empty array (normal case for no delivery data)
        final rawDeliveryData = record.data['deliveryData'];
        if (rawDeliveryData != null && rawDeliveryData is List && rawDeliveryData.isEmpty) {
          debugPrint('ℹ️ Trip has no delivery data (empty array)');
        } else {
          debugPrint('⚠️ No delivery data found in record');
        }
      }

      // Handle delivery collection data - Map to CollectionModel objects
      final deliveryCollectionList = record.expand['deliveryCollection'];
      List<collection.CollectionModel> deliveryCollectionModels = [];

      // Check both expanded data and raw data field
      if (deliveryCollectionList != null && deliveryCollectionList.isNotEmpty) {
        debugPrint('✅ Found delivery collection data: ${deliveryCollectionList.runtimeType}');

        try {
          for (var collectionItem in deliveryCollectionList) {
            deliveryCollectionModels.add(
              collection.CollectionModel.fromJson({
                'id': collectionItem.id,
                'collectionId': collectionItem.collectionId,
                'collectionName': collectionItem.collectionName,
                ...collectionItem.data,
              }),
            );
          }
          debugPrint(
            '✅ Processed ${deliveryCollectionModels.length} delivery collection items',
          );
        } catch (e) {
          debugPrint('❌ Error processing delivery collection data: $e');
        }
      } else {
        // Check if raw data has empty array (normal case for no collections)
        final rawCollectionData = record.data['deliveryCollection'];
        if (rawCollectionData != null && rawCollectionData is List && rawCollectionData.isEmpty) {
          debugPrint('ℹ️ Trip has no delivery collections (empty array)');
        } else {
          debugPrint('⚠️ No delivery collection data found in record');
        }
      }

      // Handle cancelled invoice data - Map to CancelledInvoiceModel objects
      final cancelledInvoiceList = record.expand['cancelledInvoice'];
      List<CancelledInvoiceModel> cancelledInvoiceModels = [];

      // Check both expanded data and raw data field
      if (cancelledInvoiceList != null && cancelledInvoiceList.isNotEmpty) {
        debugPrint('✅ Found cancelled invoice data: ${cancelledInvoiceList.runtimeType}');

        try {
          for (var invoiceItem in cancelledInvoiceList) {
            cancelledInvoiceModels.add(
              CancelledInvoiceModel.fromJson({
                'id': invoiceItem.id,
                'collectionId': invoiceItem.collectionId,
                'collectionName': invoiceItem.collectionName,
                ...invoiceItem.data,
              }),
            );
          }
          debugPrint(
            '✅ Processed ${cancelledInvoiceModels.length} cancelled invoice items',
          );
        } catch (e) {
          debugPrint('❌ Error processing cancelled invoice data: $e');
        }
      } else {
        // Check if raw data has empty array (normal case for no cancelled invoices)
        final rawCancelledData = record.data['cancelledInvoice'];
        if (rawCancelledData != null && rawCancelledData is List && rawCancelledData.isEmpty) {
          debugPrint('ℹ️ Trip has no cancelled invoices (empty array)');
        } else {
          debugPrint('⚠️ No cancelled invoice data found in record');
        }
      }

      final mappedData = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        ...record.data,
        'customers': _mapExpandedList(record.expand['customers']),
        'deliveryTeam': _mapExpandedItem(record.expand['deliveryTeam']),
        'personels': _mapExpandedList(record.expand['personels']),
        'vehicle':
            vehicleModel?.toJson(), // Updated: Changed to single vehicle model
        'deliveryData':
            deliveryDataModels
                .map((model) => model.toJson())
                .toList(), // Added: Map delivery data
        'checklist': _mapExpandedList(record.expand['checklist']),
        'cancelledInvoice': cancelledInvoiceModels
            .map((model) => model.toJson())
            .toList(),
        'deliveryCollection':
            deliveryCollectionModels.map((model) => model.toJson()).toList(),

        'trip_update_list': _mapExpandedList(record.expand['trip_update_list']),
        'user': usersModel?.toJson(),
        'created': record.created,
        'updated': record.updated,
        'timeAccepted': timeAccepted?.toIso8601String(),
        'timeEndTrip': timeEndTrip?.toIso8601String(),
        'longitude': record.data['longitude'],
        'latitude': record.data['latitude'],
        'volumeRate': record.data['volumeRate'],
        'weightRate': record.data['weightRate'],
        'averageFillRate': record.data['averageFillRate'],
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
