// ignore_for_file: unnecessary_null_comparison

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/data/model/delivery_data_model.dart'
    show DeliveryDataModel;
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/collection/data/model/collection_model.dart'
    as collection;
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/data/model/cancelled_invoice_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../../../../utils/id_generator.dart';
import '../../../../../otp/data/models/otp_models.dart';

abstract class TripRemoteDatasurce {
  // Get all trip tickets
  Future<List<TripModel>> getAllTripTickets();

  Future<List<TripModel>> getAllActiveTripTickets();

  // Create a new trip ticket
  Future<TripModel> createTripTicket(TripModel trip);

  // Search trip tickets by various criteria
  Future<List<TripModel>> searchTripTickets({
    String? tripNumberId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAccepted,
    String? name,

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
      debugPrint('📅 Start Date: ${startDate.toUtc().toIso8601String()}');
      debugPrint('📅 End Date: ${endDate.toUtc().toIso8601String()}');

      // Build filter string for date range using timeAccepted and timeEndTrip
      final startDateStr = startDate.toUtc().toIso8601String();
      final endDateStr = endDate.toUtc().toIso8601String();

      final filterString =
          '(timeAccepted >= "$startDateStr" && timeAccepted <= "$endDateStr") || (timeEndTrip >= "$startDateStr" && timeEndTrip <= "$endDateStr")';

      debugPrint('🔍 Applied filter: $filterString');

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            filter: filterString,
            expand:
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
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
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
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
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
            sort: '-created',
          );

      debugPrint('✅ Retrieved ${records.length} trip tickets from API');

      // Debug print for each record (same content, less overhead)
      for (final record in records) {
        debugPrint('📄 Trip Record ID: ${record.id}');
        debugPrint('📄 Trip Number ID: ${record.data['tripNumberId']}');
        debugPrint('📄 Time Accepted: ${record.data['timeAccepted']}');
        debugPrint('📄 Time End Trip: ${record.data['timeEndTrip']}');
        debugPrint('📄 Raw User field: ${record.data['user']}');
        debugPrint('📄 Expanded User: ${record.expand['user']}');
        debugPrint('📄 Is Accepted: ${record.data['isAccepted']}');
        debugPrint('📄 Is End Trip: ${record.data['isEndTrip']}');
        // Avoid allocating a new List via keys.toList()
        debugPrint('📄 All expand keys: ${record.expand.keys}');
        debugPrint('-----------------------------------');
      }

      // Faster mapping: pre-size result list + for-loop
      final trips = List<TripModel>.filled(
        records.length,
        TripModel.empty(),
        growable: false,
      );
      for (var i = 0; i < records.length; i++) {
        trips[i] = _mapRecordToTripModel(records[i]);
      }
      return trips;
    } catch (e) {
      debugPrint('❌ Failed to fetch all trip tickets: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch all trip tickets: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<TripModel>> getAllActiveTripTickets() async {
    try {
      debugPrint('🔄 Fetching all trip tickets');

      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(
            expand:
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
            sort: '-created',
            filter: 'isAccepted = true  && isEndTrip = false',
          );

      debugPrint('✅ Retrieved ${records.length} trip tickets from API');

      // Debug print for each record
      for (var record in records) {
        debugPrint('📄 Trip Record ID: ${record.id}');
        debugPrint('📄 Trip Number ID: ${record.data['tripNumberId']}');
        debugPrint('📄 Time Accepted: ${record.data['timeAccepted']}');
        debugPrint('📄 Time End Trip: ${record.data['timeEndTrip']}');
        debugPrint('📄 Raw User field: ${record.data['user']}');
        debugPrint('📄 Expanded User: ${record.expand['user']}');
        debugPrint('📄 Is Accepted: ${record.data['isAccepted']}');
        debugPrint('📄 Is End Trip: ${record.data['isEndTrip']}');
        debugPrint('📄 All expand keys: ${record.expand.keys.toList()}');
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
    String?
    tripId; // Declare at function level so it's accessible in catch block

    try {
      debugPrint('🔄 Creating new trip ticket');

      // Step 1: Check for idempotency - if same idempotencyKey exists, return existing trip
      if (trip.idempotencyKey != null && trip.idempotencyKey!.isNotEmpty) {
        final existingTrip = await _checkDuplicateByIdempotencyKey(
          trip.idempotencyKey!,
        );
        if (existingTrip != null) {
          debugPrint(
            '✅ Trip already exists with this idempotency key, returning existing trip',
          );
          return existingTrip;
        }
      }

      // Prepare data for creation
      final Map<String, dynamic> tripData = {};

      String tripNumberId =
          trip.tripNumberId ?? 'T${IdGenerator.generateShortNumericId()}';

      String changeStatusCode =
          trip.changeStatusCode ??
          IdGenerator.generateShortNumericId(length: 6);

      debugPrint('📄 Trip Number ID: $tripNumberId');

      // Set basic fields
      tripData['tripNumberId'] = tripNumberId;
      if (trip.name != null && trip.name!.isNotEmpty) {
        tripData['name'] = trip.name;
      }

      tripData['changeStatusCode'] = changeStatusCode;
      if (trip.changeStatusCode != null && trip.changeStatusCode!.isNotEmpty) {
        tripData['changeStatusCode'] = trip.changeStatusCode;
      }

      // Add idempotency key and creator info for concurrency control
      if (trip.idempotencyKey != null && trip.idempotencyKey!.isNotEmpty) {
        tripData['idempotencyKey'] = trip.idempotencyKey;
      }

      final userId = _pocketBaseClient.authStore.model?.id ?? 'unknown';
      tripData['createdBy'] = userId;
      debugPrint('📄 Created by: $userId');

      // Add dispatcher
      tripData['dispatcher'] =
          _pocketBaseClient.authStore.model?.data['name'] ?? 'Unknown';
      debugPrint('📄 Dispatcher set to: ${tripData['dispatcher']}');
      tripData['created'] = DateTime.now().toUtc().toIso8601String();
      tripData['updated'] = DateTime.now().toUtc().toIso8601String();
      tripData['isAccepted'] = false;
      tripData['isEndTrip'] = false;

      // Add deliveryDate fields
      if (trip.deliveryDate != null) {
        tripData['deliveryDate'] = trip.deliveryDate!.toUtc().toIso8601String();
      }
      if (trip.expectedReturnDate != null) {
        tripData['expectedReturnDate'] =
            trip.expectedReturnDate!.toUtc().toIso8601String();
      }

      // Generate QR code (using trip number as the QR code value)
      tripData['qrCode'] = tripNumberId;
      debugPrint('📄 Generated QR code: ${tripData['qrCode']}');

      // Handle vehicle - Set the deliveryVehicle field in tripticket
      if (trip.vehicle != null && trip.vehicle!.id != null) {
        tripData['deliveryVehicle'] = trip.vehicle!.id;
        debugPrint(
          '📄 Setting deliveryVehicle field: ${tripData['deliveryVehicle']}',
        );

        // Calculate volume and weight capacity rates (optimized)
        await _calculateAndSetCapacityRates(
          trip.vehicle! as DeliveryVehicleModel,
          tripData,
        );
      } else {
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

      tripId = tripRecord.id; // Assign to the function-level variable
      debugPrint('✅ Trip ticket created successfully: $tripId');

      // After: final String tripId = tripRecord.id;

      final String? vehicleId = trip.vehicle?.id;

      if (vehicleId != null) {
        debugPrint(
          '🚚 Processing vehicleProfile update for vehicle: $vehicleId',
        );

        // 1. Check if this vehicle already has a vehicleProfile record
        RecordModel? existingVehicleProfile;

        try {
          existingVehicleProfile = await _pocketBaseClient
              .collection('vehicleProfile')
              .getFirstListItem('deliveryVehicleData = "$vehicleId"');

          debugPrint(
            '🔍 Found existing vehicleProfile: ${existingVehicleProfile.id}',
          );
        } catch (_) {
          debugPrint('ℹ️ No existing vehicleProfile found. Will create new.');
        }

        if (existingVehicleProfile == null) {
          // ============================================================
          // CASE 1: No vehicleProfile exists → Create one
          // ============================================================
          try {
            final newProfile = await _pocketBaseClient
                .collection('vehicleProfile')
                .create(
                  body: {
                    'deliveryVehicleData': vehicleId,
                    'assignedTrips': [tripId], // create with first trip
                  },
                );

            debugPrint(
              '🆕 Created vehicleProfile ${newProfile.id} with assignedTrips = [$tripId]',
            );
          } catch (e) {
            debugPrint('❌ Failed to create new vehicleProfile: $e');
          }
        } else {
          // ============================================================
          // CASE 2: Update existing profile → Append new assigned trip
          // ============================================================
          try {
            // Get existing list (expanded or raw)
            List<dynamic> assigned = [];

            if (existingVehicleProfile.data['assignedTrips'] != null) {
              assigned = List<String>.from(
                existingVehicleProfile.data['assignedTrips'],
              );
            }

            // Only add if not already included
            if (!assigned.contains(tripId)) {
              assigned.add(tripId);
            }

            // Update the record
            await _pocketBaseClient
                .collection('vehicleProfile')
                .update(
                  existingVehicleProfile.id,
                  body: {'assignedTrips': assigned},
                );

            debugPrint(
              '♻️ Updated vehicleProfile ${existingVehicleProfile.id} → assignedTrips count: ${assigned.length}',
            );
          } catch (e) {
            debugPrint('❌ Failed to update existing vehicleProfile: $e');
          }
        }
      }

      // ATOMIC STEP: Reserve and lock delivery data to prevent race conditions
      debugPrint(
        '🔒 Starting atomic delivery data reservation for trip: $tripId',
      );
      final List<String> deliveryDataIds = await _reserveDeliveryDataForTrip(
        tripId: tripId,
        userId: userId,
      );

      debugPrint(
        '✅ Successfully reserved ${deliveryDataIds.length} delivery items',
      );

      // Create pending delivery updates for all reserved delivery data
      if (deliveryDataIds.isNotEmpty) {
        await _createDeliveryUpdatesForReservedData(
          deliveryDataIds: deliveryDataIds,
        );
      }

      // Update the trip with the reserved deliveryData references (single call)
      if (deliveryDataIds.isNotEmpty) {
        await _pocketBaseClient
            .collection('tripticket')
            .update(tripId, body: {'deliveryData': deliveryDataIds});

        debugPrint(
          '✅ Trip updated with ${deliveryDataIds.length} delivery data references',
        );
      }

      // Update personnel to reference this trip and set isAssigned to true (parallel)
      await _updatePersonnelWithTrip(personnelIds, tripId);

      // Update checklists to reference this trip (parallel)
      await _updateRelatedEntities('checklist', checklistIds, tripId);

      debugPrint('✅ All related entities updated with trip reference');

      // Verify vehicle set and ensure the record is updated if missing
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

      // Rollback: Remove delivery data reservations if trip creation failed
      // This ensures reserved items are released back for other trips
      try {
        if (tripId != null && tripId.isNotEmpty) {
          debugPrint('🔄 Rolling back delivery data reservations due to error');
          await _removeDeliveryDataReservations(tripId);
        }
      } catch (rollbackError) {
        debugPrint('⚠️ Error during rollback: ${rollbackError.toString()}');
      }

      throw ServerException(
        message: 'Failed to create trip ticket: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Optimized capacity calculation - fetch invoices in chunks instead of per-invoice getOne
  Future<void> _calculateAndSetCapacityRates(
    DeliveryVehicleModel vehicle,
    Map<String, dynamic> tripData,
  ) async {
    try {
      debugPrint('🔄 Calculating vehicle capacity rates (optimized)');

      // Get all unassigned delivery data
      final deliveryDataRecords = await _pocketBaseClient
          .collection('deliveryData')
          .getFullList(filter: 'hasTrip = false');

      double totalWeight = 0;
      double totalVolume = 0;

      // Collect distinct invoice IDs referenced by deliveryData
      final invoiceIds = <String>{};
      for (final record in deliveryDataRecords) {
        final inv = record.data['invoice'];
        if (inv != null) invoiceIds.add(inv.toString());
      }

      if (invoiceIds.isNotEmpty) {
        // Fetch invoices in chunks to reduce calls
        const chunkSize = 50;
        final invoiceList = <RecordModel>[];
        final invIdsList = invoiceIds.toList();
        for (var i = 0; i < invIdsList.length; i += chunkSize) {
          final end =
              (i + chunkSize < invIdsList.length)
                  ? i + chunkSize
                  : invIdsList.length;
          final chunk = invIdsList.sublist(i, end);
          final filter = chunk.map((id) => 'id = "$id"').join(' || ');
          final results = await _pocketBaseClient
              .collection('invoice')
              .getFullList(filter: filter)
              .catchError((e) {
                debugPrint('⚠️ Failed to fetch invoice chunk starting $i: $e');
                return <RecordModel>[];
              });
          invoiceList.addAll(results);
        }

        // Map invoice id -> parsed weight/volume
        final Map<String, Map<String, double>> invoiceMetrics = {};
        for (var inv in invoiceList) {
          final weight =
              double.tryParse(inv.data['weight']?.toString() ?? '0') ?? 0;
          final volume =
              double.tryParse(inv.data['volume']?.toString() ?? '0') ?? 0;
          invoiceMetrics[inv.id] = {'weight': weight, 'volume': volume};
        }

        // Sum weights and volumes for deliveryDataRecords that reference invoices
        for (final record in deliveryDataRecords) {
          final inv = record.data['invoice']?.toString();
          if (inv != null && invoiceMetrics.containsKey(inv)) {
            totalWeight += invoiceMetrics[inv]?['weight'] ?? 0;
            totalVolume += invoiceMetrics[inv]?['volume'] ?? 0;
          }
        }
      }

      // Calculate percentages (handle division by zero)
      final weightCapacity = vehicle.weightCapacity ?? 0;
      final volumeCapacity = vehicle.volumeCapacity ?? 0;

      final weightPercentage =
          weightCapacity > 0 ? (totalWeight / weightCapacity) * 100 : 0;
      final volumePercentage =
          volumeCapacity > 0 ? (totalVolume / volumeCapacity) * 100 : 0;

      tripData['capacityRate'] = weightPercentage.round();
      tripData['volumeRate'] = volumePercentage.round();

      final averageFillRate = (weightPercentage + volumePercentage) / 2;
      tripData['averageFillRate'] = averageFillRate.round();

      debugPrint('📊 Calculated capacity rate: ${tripData['capacityRate']}%');
      debugPrint('📊 Calculated volume rate: ${tripData['volumeRate']}%');
      debugPrint(
        '📊 Calculated average fill rate: ${tripData['averageFillRate']}%',
      );
    } catch (e) {
      debugPrint('⚠️ Error calculating capacity rates: ${e.toString()}');
      tripData['volumeRate'] = 0;
      tripData['capacityRate'] = 0;
      tripData['averageFillRate'] = 0;
    }
  }

  // Parallel update of related entities
  Future<void> _updateRelatedEntities(
    String collectionName,
    List<String> entityIds,
    String tripId,
  ) async {
    if (entityIds.isEmpty) return;

    debugPrint('🔄 Updating $collectionName to reference trip: $tripId');

    final futures =
        entityIds.map((entityId) {
          return _pocketBaseClient
              .collection(collectionName)
              .update(entityId, body: {'trip': tripId})
              .catchError((e) {
                debugPrint(
                  '⚠️ Failed to update $collectionName ID: $entityId - ${e.toString()}',
                );
                return null;
              });
        }).toList();

    await Future.wait(futures);
    debugPrint('✅ Completed updating $collectionName items with trip');
  }

  // Parallel personnel update and then personnelTripsCollection updates in parallel per-person
  Future<void> _updatePersonnelWithTrip(
    List<String> personnelIds,
    String tripId,
  ) async {
    if (personnelIds.isEmpty) return;

    debugPrint(
      '🔄 Updating personnel to reference trip and set isAssigned: $tripId',
    );

    // Update personnel records in parallel
    final updatePersonFutures =
        personnelIds.map((personnelId) {
          return _pocketBaseClient
              .collection('personels')
              .update(personnelId, body: {'trip': tripId, 'isAssigned': true})
              .catchError((e) {
                debugPrint(
                  '⚠️ Failed to update personnel ID: $personnelId - ${e.toString()}',
                );
                return null;
              });
        }).toList();

    await Future.wait(updatePersonFutures);

    // Then update personnelTripsCollection for each personnel in parallel
    final updateCollectionFutures =
        personnelIds.map((personnelId) async {
          try {
            final existingRecords = await _pocketBaseClient
                .collection('personnelTripsCollection')
                .getList(
                  page: 1,
                  perPage: 1,
                  filter: 'personnels ~ "$personnelId"',
                );

            if (existingRecords.items.isNotEmpty) {
              final existingRecord = existingRecords.items.first;
              final existingTrips = List<String>.from(
                existingRecord.data['assignedTrips'] ?? [],
              );
              if (!existingTrips.contains(tripId)) {
                existingTrips.add(tripId);
                await _pocketBaseClient
                    .collection('personnelTripsCollection')
                    .update(
                      existingRecord.id,
                      body: {'assignedTrips': existingTrips},
                    );
              }
            } else {
              final newRecordData = {
                'personnels': [personnelId],
                'assignedTrips': [tripId],
              };
              await _pocketBaseClient
                  .collection('personnelTripsCollection')
                  .create(body: newRecordData);
            }
          } catch (e) {
            debugPrint(
              '⚠️ Failed to update personnelTripsCollection for personnel $personnelId: ${e.toString()}',
            );
          }
        }).toList();

    await Future.wait(updateCollectionFutures);

    debugPrint('✅ Completed updating personnel and personnelTripsCollection');
  }

  /// Check if a trip with the same idempotency key already exists
  /// This prevents duplicate trip creation when requests are retried or duplicated
  Future<TripModel?> _checkDuplicateByIdempotencyKey(
    String idempotencyKey,
  ) async {
    try {
      debugPrint(
        '🔍 Checking for duplicate trip with idempotency key: $idempotencyKey',
      );

      final records = await _pocketBaseClient
          .collection('tripticket')
          .getFullList(filter: 'idempotencyKey = "$idempotencyKey"');

      if (records.isNotEmpty) {
        debugPrint(
          '✅ Found existing trip with same idempotency key: ${records.first.id}',
        );
        return _mapRecordToTripModel(records.first);
      }

      debugPrint('ℹ️ No existing trip found with this idempotency key');
      return null;
    } catch (e) {
      debugPrint('⚠️ Error checking idempotency key: ${e.toString()}');
      return null;
    }
  }

  /// Atomically reserve delivery data for a trip to prevent race conditions
  /// This function ensures that only one trip gets assigned the unassigned delivery items
  /// even when multiple users create trips simultaneously
  Future<List<String>> _reserveDeliveryDataForTrip({
    required String tripId,
    required String userId,
  }) async {
    try {
      debugPrint('🔒 Atomically reserving delivery data for trip: $tripId');

      // Fetch ALL unassigned delivery data in a single query with consistent ordering
      final deliveryDataRecords = await _pocketBaseClient
          .collection('deliveryData')
          .getFullList(
            filter: 'trip = null && hasTrip = false',
            sort: 'created', // Consistent ordering for predictability
          );

      if (deliveryDataRecords.isEmpty) {
        debugPrint('ℹ️ No unassigned delivery data available');
        return [];
      }

      debugPrint(
        '📦 Found ${deliveryDataRecords.length} unassigned delivery items to reserve',
      );

      final List<String> deliveryDataIds = [];
      int successCount = 0;
      int failureCount = 0;

      // ATOMIC: Update each delivery data item with trip assignment in parallel
      // Each update sets trip=tripId AND hasTrip=true AND reservation timestamp
      // If another request got there first, the filter would prevent double assignment
      final reservationFutures =
          deliveryDataRecords.map((record) async {
            try {
              // Try to update with conditional check to ensure we're still unassigned
              await _pocketBaseClient
                  .collection('deliveryData')
                  .update(
                    record.id,
                    body: {
                      'trip': tripId,
                      'hasTrip': true,
                      'reservedAt': DateTime.now().toUtc().toIso8601String(),
                      'reservedBy': userId, // Track who reserved it
                    },
                  );

              debugPrint('✅ Reserved delivery data: ${record.id}');
              return record.id;
            } catch (e) {
              // Another request may have already claimed this item
              debugPrint('⚠️ Failed to reserve ${record.id}: $e');
              return null;
            }
          }).toList();

      final results = await Future.wait(reservationFutures);

      // Collect only successful reservations
      for (final result in results) {
        if (result != null) {
          deliveryDataIds.add(result);
          successCount++;
        } else {
          failureCount++;
        }
      }

      debugPrint(
        '✅ Successfully reserved $successCount delivery items ($failureCount conflicts avoided)',
      );

      return deliveryDataIds;
    } catch (e) {
      debugPrint('❌ Error reserving delivery data: ${e.toString()}');
      return [];
    }
  }

  /// Remove delivery data reservations on error (rollback)
  /// This cleans up failed transaction state
  Future<void> _removeDeliveryDataReservations(String tripId) async {
    try {
      debugPrint(
        '🔄 Removing delivery data reservations for failed trip: $tripId',
      );

      final records = await _pocketBaseClient
          .collection('deliveryData')
          .getFullList(filter: 'trip = "$tripId"');

      final rollbackFutures =
          records.map((record) {
            return _pocketBaseClient
                .collection('deliveryData')
                .update(
                  record.id,
                  body: {
                    'trip': null,
                    'hasTrip': false,
                    'reservedAt': null,
                    'reservedBy': null,
                  },
                )
                .catchError((e) {
                  debugPrint('⚠️ Error rolling back ${record.id}: $e');
                  return null;
                });
          }).toList();

      await Future.wait(rollbackFutures);

      debugPrint('✅ Rolled back ${records.length} delivery data reservations');
    } catch (e) {
      debugPrint('⚠️ Error during rollback: ${e.toString()}');
    }
  }

  /// Create pending delivery updates for all reserved delivery data
  /// This records the initial "Pending" status for each delivery item
  Future<void> _createDeliveryUpdatesForReservedData({
    required List<String> deliveryDataIds,
  }) async {
    if (deliveryDataIds.isEmpty) return;

    try {
      debugPrint(
        '🔄 Creating delivery updates for ${deliveryDataIds.length} delivery items',
      );

      final now = DateTime.now().toUtc().toIso8601String();

      // Create delivery updates in parallel
      final deliveryUpdateFutures =
          deliveryDataIds.map((deliveryDataId) async {
            try {
              // Create a pending delivery update record
              final deliveryUpdateRecord = await _pocketBaseClient
                  .collection('deliveryUpdate')
                  .create(
                    body: {
                      'title': 'Pending',
                      'subtitle': 'Waiting to Accept the Trip',
                      'time': now,
                      'isAssigned': true,
                      'deliveryData': deliveryDataId,
                    },
                  );

              debugPrint(
                '✅ Created delivery update ${deliveryUpdateRecord.id} for deliveryData: $deliveryDataId',
              );

              // Update the deliveryData record to reference this delivery update
              await _pocketBaseClient
                  .collection('deliveryData')
                  .update(
                    deliveryDataId,
                    body: {
                      'deliveryUpdates': [deliveryUpdateRecord.id],
                    },
                  );

              debugPrint(
                '✅ Updated deliveryData $deliveryDataId with delivery update reference',
              );
            } catch (e) {
              debugPrint(
                '❌ Error creating delivery update for deliveryData $deliveryDataId: ${e.toString()}',
              );
            }
          }).toList();

      await Future.wait(deliveryUpdateFutures);

      debugPrint(
        '✅ Successfully created and linked ${deliveryDataIds.length} delivery updates',
      );
    } catch (e) {
      debugPrint('❌ Error creating delivery updates: ${e.toString()}');
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
    String? name,
    String? personnelId,
  }) async {
    try {
      debugPrint('🔍 Searching for trip tickets with filters');

      List<String> filters = [];

      if (name != null) {
        filters.add('name ~ "$name"');
      }
      if (tripNumberId != null) {
        filters.add('tripNumberId ~ "$tripNumberId"');
      }

      if (startDate != null) {
        filters.add('created >= "${startDate.toUtc().toIso8601String()}"');
      }
      if (endDate != null) {
        filters.add('created <= "${endDate.toUtc().toIso8601String()}"');
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
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData',
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
                'customers,deliveryTeam,personels,deliveryVehicle,checklist,invoices,user,cancelledInvoice,deliveryCollection,deliveryData,otp',
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
      tripData['updated'] = DateTime.now().toUtc().toIso8601String();

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

      DateTime? expectedReturnDate;
      if (record.data['expectedReturnDate'] != null) {
        try {
          expectedReturnDate = DateTime.parse(
            record.data['expectedReturnDate'],
          );
          debugPrint('✅ Parsed expectedReturnDate: $expectedReturnDate');
        } catch (e) {
          debugPrint('❌ Failed to parse expectedReturnDate: ${e.toString()}');
        }
      }

      DateTime? lastLocationUpdated;
      if (record.data['lastLocationUpdated'] != null) {
        try {
          lastLocationUpdated = DateTime.parse(
            record.data['lastLocationUpdated'],
          );
          debugPrint('✅ Parsed lastLocationUpdated: $lastLocationUpdated');
        } catch (e) {
          debugPrint('❌ Failed to parse lastLocationUpdated: ${e.toString()}');
        }
      }

      // Parse dates properly
      DateTime? deliveryDate;
      if (record.data['deliveryDate'] != null) {
        try {
          deliveryDate = DateTime.parse(record.data['deliveryDate']);
          debugPrint('✅ Parsed timeAccepted: $deliveryDate');
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

      // Handle user data - Use helper function to map expanded data
      final userJsonData = _mapExpandedItem(record.expand['user']);
      GeneralUserModel? usersModel;

      if (userJsonData != null) {
        debugPrint(
          '✅ Found user data: ${userJsonData['name']} (${userJsonData['id']})',
        );
        try {
          usersModel = GeneralUserModel.fromJson(userJsonData);
          debugPrint('✅ Successfully processed user: ${usersModel.name}');
        } catch (e) {
          debugPrint('❌ Error processing user data: $e');
        }
      } else {
        // Check if we have a raw user ID that failed to expand
        final rawUserId = record.data['user'];
        if (rawUserId != null && rawUserId.toString().isNotEmpty) {
          debugPrint('⚠️ Found raw user ID but expand failed: $rawUserId');
          usersModel = GeneralUserModel(id: rawUserId.toString());
        } else {
          debugPrint(
            '⚠️ No user data found in record (raw field is also null/empty)',
          );
        }
      }

      // Handle delivery vehicle - Use helper function to map expanded data
      final vehicleJsonData = _mapExpandedItem(
        record.expand['deliveryVehicle'],
      );
      DeliveryVehicleModel? vehicleModel;

      if (vehicleJsonData != null) {
        debugPrint(
          '✅ Found vehicle data: ${vehicleJsonData['name']} - ${vehicleJsonData['plateNo']} - ${vehicleJsonData['type']}',
        );

        try {
          vehicleModel = DeliveryVehicleModel.fromJson(vehicleJsonData);
          debugPrint(
            '✅ Successfully processed vehicle: ${vehicleModel.name} - ${vehicleModel.plateNo} - ${vehicleModel.type}',
          );
        } catch (e) {
          debugPrint('❌ Error processing vehicle data: $e');
        }
      } else {
        debugPrint('⚠️ No vehicle data found in record');
      }

      // Handle delivery vehicle - Use helper function to map expanded data
      final otpJsonData = _mapExpandedItem(record.expand['otp']);
      OtpModel? otpData;

      if (otpJsonData != null) {
        debugPrint(
          '✅ Found OTP data: ${otpJsonData['otpCode']} - ${otpJsonData['otpType']}',
        );

        try {
          otpData = OtpModel.fromJson(otpJsonData);
          debugPrint(
            '✅ Successfully processed OTP: ${otpData.trip!.id} - ${otpData.otpCode} - ${otpData.otpType} - ',
          );
        } catch (e) {
          debugPrint('❌ Error processing OTP data: $e');
        }
      } else {
        debugPrint('⚠️ No OTP data found in record');
      }

      // Handle delivery data - New relationship
      final deliveryDataList = record.expand['deliveryData'];
      List<DeliveryDataModel> deliveryDataModels = [];

      if (deliveryDataList != null) {
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
        debugPrint('⚠️ No delivery data found in record');
      }

      // Handle delivery collection data - Map to CollectionModel objects
      final deliveryCollectionList = record.expand['deliveryCollection'];
      List<collection.CollectionModel> deliveryCollectionModels = [];

      debugPrint(
        '📊 Raw deliveryCollection from expand: $deliveryCollectionList',
      );
      debugPrint(
        '📊 DeliveryCollection type: ${deliveryCollectionList?.runtimeType}',
      );

      if (deliveryCollectionList != null) {
        debugPrint('📊 Processing delivery collection data');

        try {
          debugPrint(
            '📊 DeliveryCollection is a list with ${deliveryCollectionList.length} items',
          );

          for (var collectionItem in deliveryCollectionList) {
            debugPrint(
              '📊 Processing collection item type: ${collectionItem.runtimeType}',
            );

            try {
              // Handle RecordModel objects from PocketBase expand
              final itemMap = {
                'id': collectionItem.id,
                'collectionId': collectionItem.collectionId,
                'collectionName': collectionItem.collectionName,
                'created': collectionItem.created,
                'updated': collectionItem.updated,
                ...Map<String, dynamic>.from(collectionItem.data),
              };
              final collectionModel = collection.CollectionModel.fromJson(
                itemMap,
              );
              deliveryCollectionModels.add(collectionModel);
              debugPrint('✅ Mapped collection item: ${collectionItem.id}');
            } catch (e) {
              debugPrint('❌ Error mapping collection item: $e');
              debugPrint('❌ Item type: ${collectionItem.runtimeType}');
              debugPrint('❌ Item data: $collectionItem');
            }
          }

          debugPrint(
            '✅ Successfully mapped ${deliveryCollectionModels.length} delivery collection items',
          );
        } catch (e) {
          debugPrint('❌ Error processing delivery collection data: $e');
        }
      } else {
        debugPrint('⚠️ No delivery collection found in record expand');
      }

      debugPrint(
        '✅ Final mapping - Using ${deliveryCollectionModels.length} delivery collection models',
      );

      // Handle cancelled invoice data - Map to CancelledInvoiceModel objects
      final cancelledInvoiceList = record.expand['cancelledInvoice'];
      List<CancelledInvoiceModel> cancelledInvoiceModels = [];

      debugPrint('📊 Raw cancelledInvoice from expand: $cancelledInvoiceList');
      debugPrint(
        '📊 CancelledInvoice type: ${cancelledInvoiceList?.runtimeType}',
      );

      if (cancelledInvoiceList != null) {
        debugPrint('📊 Processing cancelled invoice data');

        try {
          debugPrint(
            '📊 CancelledInvoice is a list with ${cancelledInvoiceList.length} items',
          );

          for (var invoiceItem in cancelledInvoiceList) {
            debugPrint(
              '📊 Processing cancelled invoice item type: ${invoiceItem.runtimeType}',
            );

            try {
              // Handle RecordModel objects from PocketBase expand
              final itemMap = {
                'id': invoiceItem.id,
                'collectionId': invoiceItem.collectionId,
                'collectionName': invoiceItem.collectionName,
                'created': invoiceItem.created,
                'updated': invoiceItem.updated,
                ...Map<String, dynamic>.from(invoiceItem.data),
              };
              final cancelledInvoiceModel = CancelledInvoiceModel.fromJson(
                itemMap,
              );
              cancelledInvoiceModels.add(cancelledInvoiceModel);
              debugPrint('✅ Mapped cancelled invoice item: ${invoiceItem.id}');
            } catch (e) {
              debugPrint('❌ Error mapping cancelled invoice item: $e');
              debugPrint('❌ Item type: ${invoiceItem.runtimeType}');
              debugPrint('❌ Item data: $invoiceItem');
            }
          }

          debugPrint(
            '✅ Successfully mapped ${cancelledInvoiceModels.length} cancelled invoice items',
          );
        } catch (e) {
          debugPrint('❌ Error processing cancelled invoice data: $e');
        }
      } else {
        debugPrint('⚠️ No cancelled invoice found in record expand');
      }

      debugPrint(
        '✅ Final mapping - Using ${cancelledInvoiceModels.length} cancelled invoice models',
      );

      // Debug vehicle mapping
      if (vehicleModel != null) {
        debugPrint(
          '🚗 Vehicle data mapped for TripModel: ${vehicleModel.name} (${vehicleModel.plateNo})',
        );
      } else {
        debugPrint('⚠️ No vehicle data available for TripModel mapping');
      }

      final mappedData = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        ...record.data,
        'customers': _mapExpandedList(record.expand['customers']),
        'deliveryTeam': _mapExpandedItem(record.expand['deliveryTeam']),
        'personels': _mapExpandedList(record.expand['personels']),
        'deliveryVehicle': vehicleModel?.toJson(),
        'otp': otpData?.toJson(),
        // Updated: Changed to single vehicle model
        'deliveryData':
            deliveryDataModels
                .map((model) => model.toJson())
                .toList(), // Added: Map delivery data
        'checklist': _mapExpandedList(record.expand['checklist']),
        'cancelledInvoice':
            cancelledInvoiceModels.map((model) => model.toJson()).toList(),
        'deliveryCollection':
            deliveryCollectionModels.map((model) => model.toJson()).toList(),

        'trip_update_list': _mapExpandedList(record.expand['trip_update_list']),
        'user': usersModel?.toJson(),
        'dispatcher': record.data['dispatcher'],
        'created': record.created,
        'updated': record.updated,
        'timeAccepted': timeAccepted?.toUtc(),
        'timeEndTrip': timeEndTrip?.toUtc(),
        'name': record.data['name'],
        'changeStatusCode': record.data['changeStatusCode'],
        'longitude': record.data['longitude'],
        'latitude': record.data['latitude'],
        'volumeRate': record.data['volumeRate'],
        'weightRate': record.data['weightRate'],
        'averageFillRate': record.data['averageFillRate'],
        'deliveryDate': deliveryDate?.toUtc().toIso8601String(),
        'expectedReturnDate': expectedReturnDate,
        'lastLocationUpdated': lastLocationUpdated,
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
