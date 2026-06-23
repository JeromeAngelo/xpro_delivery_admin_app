import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

abstract class DeliveryVehicleRemoteDataSource {
  /// Loads a specific delivery vehicle by its ID
  Future<DeliveryVehicleModel> loadDeliveryVehicleById(String id);

  /// Loads all delivery vehicles associated with a specific trip
  Future<List<DeliveryVehicleModel>> loadDeliveryVehiclesByTripId(
    String tripId,
  );

  /// Loads all delivery vehicles in the system
  Future<List<DeliveryVehicleModel>> loadAllDeliveryVehicles();

  /// Creates a new delivery vehicle
  Future<DeliveryVehicleModel> createDeliveryVehicle(
    DeliveryVehicleModel vehicle,
  );

  /// Updates an existing delivery vehicle
  Future<DeliveryVehicleModel> updateDeliveryVehicle(
    String id,
    DeliveryVehicleModel vehicle,
  );
}

class DeliveryVehicleRemoteDataSourceImpl
    implements DeliveryVehicleRemoteDataSource {
  final PocketBase _pocketBaseClient;

  const DeliveryVehicleRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  @override
  Future<DeliveryVehicleModel> loadDeliveryVehicleById(String id) async {
    try {
      debugPrint('🔄 Loading delivery vehicle with ID: $id');

      final record = await _pocketBaseClient
          .collection('deliveryVehicleData')
          .getOne(id);

      final vehicle = DeliveryVehicleModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'name': record.data['name'],
        'plate_no': record.data['plate_no'],
        'make': record.data['make'],
        'type': record.data['type'],
        'wheels': record.data['wheels'],
        'volumeCapacity': record.data['volumeCapacity'],
        'weightCapacity': record.data['weightCapacity'],
        'created': record.created,
        'updated': record.updated,
      });

      debugPrint('✅ Successfully loaded delivery vehicle: ${vehicle.name}');
      return vehicle;
    } catch (e) {
      debugPrint('❌ Error loading delivery vehicle: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load delivery vehicle: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<DeliveryVehicleModel>> loadDeliveryVehiclesByTripId(
    String tripId,
  ) async {
    try {
      debugPrint('🔄 Loading delivery vehicles for trip ID: $tripId');

      final records = await _pocketBaseClient
          .collection('deliveryVehicleData')
          .getFullList(filter: 'trip = "$tripId"');

      final vehicles =
          records
              .map(
                (record) => DeliveryVehicleModel.fromJson({
                  'id': record.id,
                  'collectionId': record.collectionId,
                  'collectionName': record.collectionName,
                  'name': record.data['name'],
                  'plate_no': record.data['plate_no'],
                  'make': record.data['make'],
                  'type': record.data['type'],
                  'wheels': record.data['wheels'],
                  'volumeCapacity': record.data['volumeCapacity'],
                  'weightCapacity': record.data['weightCapacity'],
                  'created': record.created,
                  'updated': record.updated,
                }),
              )
              .toList();

      debugPrint(
        '✅ Successfully loaded ${vehicles.length} delivery vehicles for trip',
      );
      return vehicles;
    } catch (e) {
      debugPrint('❌ Error loading delivery vehicles by trip: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load delivery vehicles for trip: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<DeliveryVehicleModel>> loadAllDeliveryVehicles() async {
    try {
      debugPrint('🔄 Loading all delivery vehicles');

      final records =
          await _pocketBaseClient
              .collection('deliveryVehicleData')
              .getFullList();

      final vehicles =
          records
              .map(
                (record) => DeliveryVehicleModel.fromJson({
                  'id': record.id,
                  'collectionId': record.collectionId,
                  'collectionName': record.collectionName,
                  'name': record.data['name'],
                  'plate_no': record.data['plate_no'],
                  'make': record.data['make'],
                  'type': record.data['type'],
                  'wheels': record.data['wheels'],
                  'volumeCapacity': record.data['volumeCapacity'],
                  'weightCapacity': record.data['weightCapacity'],
                  'created': record.created,
                  'updated': record.updated,
                }),
              )
              .toList();

      debugPrint('✅ Successfully loaded ${vehicles.length} delivery vehicles');
      return vehicles;
    } catch (e) {
      debugPrint('❌ Error loading all delivery vehicles: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all delivery vehicles: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<DeliveryVehicleModel> createDeliveryVehicle(
    DeliveryVehicleModel vehicle,
  ) async {
    try {
      debugPrint('🆕 Creating delivery vehicle...');

      final body = <String, dynamic>{
        if (vehicle.name != null && vehicle.name!.isNotEmpty)
          'name': vehicle.name,
        if (vehicle.plateNo != null && vehicle.plateNo!.isNotEmpty)
          'plate_no': vehicle.plateNo,
        if (vehicle.make != null && vehicle.make!.isNotEmpty)
          'make': vehicle.make,
        if (vehicle.type != null && vehicle.type!.isNotEmpty)
          'type': vehicle.type,
        if (vehicle.wheels != null && vehicle.wheels!.isNotEmpty)
          'wheels': vehicle.wheels,
        if (vehicle.volumeCapacity != null)
          'volumeCapacity': vehicle.volumeCapacity,
        if (vehicle.weightCapacity != null)
          'weightCapacity': vehicle.weightCapacity,
      };

      debugPrint('📦 Payload to PocketBase: $body');

      final record = await _pocketBaseClient
          .collection('deliveryVehicleData')
          .create(body: body);

      debugPrint('✅ Delivery vehicle created: ${record.id}');

      return DeliveryVehicleModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'name': record.data['name'],
        'plate_no': record.data['plate_no'],
        'make': record.data['make'],
        'type': record.data['type'],
        'wheels': record.data['wheels'],
        'volumeCapacity': record.data['volumeCapacity'],
        'weightCapacity': record.data['weightCapacity'],
        'created': record.created,
        'updated': record.updated,
      });
    } catch (e) {
      debugPrint('❌ Error creating delivery vehicle: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create delivery vehicle: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<DeliveryVehicleModel> updateDeliveryVehicle(
    String id,
    DeliveryVehicleModel vehicle,
  ) async {
    try {
      debugPrint('🔄 Updating delivery vehicle with ID: $id');

      final body = <String, dynamic>{
        if (vehicle.name != null) 'name': vehicle.name,
        if (vehicle.plateNo != null) 'plate_no': vehicle.plateNo,
        if (vehicle.make != null) 'make': vehicle.make,
        if (vehicle.type != null) 'type': vehicle.type,
        if (vehicle.wheels != null) 'wheels': vehicle.wheels,
        if (vehicle.volumeCapacity != null)
          'volumeCapacity': vehicle.volumeCapacity,
        if (vehicle.weightCapacity != null)
          'weightCapacity': vehicle.weightCapacity,
      };

      debugPrint('📦 Payload to PocketBase: $body');

      final record = await _pocketBaseClient
          .collection('deliveryVehicleData')
          .update(id, body: body);

      debugPrint('✅ Delivery vehicle updated: ${record.id}');

      return DeliveryVehicleModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'name': record.data['name'],
        'plate_no': record.data['plate_no'],
        'make': record.data['make'],
        'type': record.data['type'],
        'wheels': record.data['wheels'],
        'volumeCapacity': record.data['volumeCapacity'],
        'weightCapacity': record.data['weightCapacity'],
        'created': record.created,
        'updated': record.updated,
      });
    } catch (e) {
      debugPrint('❌ Error updating delivery vehicle: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update delivery vehicle: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
