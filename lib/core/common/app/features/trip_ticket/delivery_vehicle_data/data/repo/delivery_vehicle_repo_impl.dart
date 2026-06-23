import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/datasource/remote_datasource/delivery_vehicle_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/repo/delivery_vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class DeliveryVehicleRepoImpl implements DeliveryVehicleRepo {
  final DeliveryVehicleRemoteDataSource _remoteDataSource;

  const DeliveryVehicleRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<DeliveryVehicleEntity> loadDeliveryVehicleById(String id) async {
    try {
      debugPrint('🔄 Repository: Loading delivery vehicle with ID: $id');
      final vehicle = await _remoteDataSource.loadDeliveryVehicleById(id);
      debugPrint('✅ Repository: Successfully loaded delivery vehicle');
      return Right(vehicle);
    } on ServerException catch (e) {
      debugPrint(
        '❌ Repository: Server error loading delivery vehicle: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ Repository: Unexpected error loading delivery vehicle: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<DeliveryVehicleEntity>> loadDeliveryVehiclesByTripId(
    String tripId,
  ) async {
    try {
      debugPrint(
        '🔄 Repository: Loading delivery vehicles for trip ID: $tripId',
      );
      final vehicles = await _remoteDataSource.loadDeliveryVehiclesByTripId(
        tripId,
      );
      debugPrint(
        '✅ Repository: Successfully loaded ${vehicles.length} delivery vehicles for trip',
      );
      return Right(vehicles);
    } on ServerException catch (e) {
      debugPrint(
        '❌ Repository: Server error loading delivery vehicles by trip: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ Repository: Unexpected error loading delivery vehicles by trip: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<DeliveryVehicleEntity>> loadAllDeliveryVehicles() async {
    try {
      debugPrint('🔄 Repository: Loading all delivery vehicles');
      final vehicles = await _remoteDataSource.loadAllDeliveryVehicles();
      debugPrint(
        '✅ Repository: Successfully loaded ${vehicles.length} delivery vehicles',
      );
      return Right(vehicles);
    } on ServerException catch (e) {
      debugPrint(
        '❌ Repository: Server error loading all delivery vehicles: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ Repository: Unexpected error loading all delivery vehicles: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<DeliveryVehicleEntity> createDeliveryVehicle(
    DeliveryVehicleEntity vehicle,
  ) async {
    try {
      debugPrint('🔄 Repository: Creating delivery vehicle');
      final created = await _remoteDataSource.createDeliveryVehicle(
        vehicle as DeliveryVehicleModel,
      );
      debugPrint(
        '✅ Repository: Successfully created delivery vehicle: ${created.id}',
      );
      return Right(created);
    } on ServerException catch (e) {
      debugPrint(
        '❌ Repository: Server error creating delivery vehicle: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ Repository: Unexpected error creating delivery vehicle: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<DeliveryVehicleEntity> updateDeliveryVehicle(
    String id,
    DeliveryVehicleEntity vehicle,
  ) async {
    try {
      debugPrint('🔄 Repository: Updating delivery vehicle with ID: $id');
      final updated = await _remoteDataSource.updateDeliveryVehicle(
        id,
        vehicle as DeliveryVehicleModel,
      );
      debugPrint(
        '✅ Repository: Successfully updated delivery vehicle: ${updated.id}',
      );
      return Right(updated);
    } on ServerException catch (e) {
      debugPrint(
        '❌ Repository: Server error updating delivery vehicle: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ Repository: Unexpected error updating delivery vehicle: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
