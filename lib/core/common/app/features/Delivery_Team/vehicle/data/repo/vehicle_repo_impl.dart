import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/data/datasource/remote_datasource/vehicle_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/entity/vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/repo/vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class VehicleRepoImpl implements VehicleRepo {
  final VehicleRemoteDatasource _remoteDatasource;

  const VehicleRepoImpl(this._remoteDatasource);

  @override
  ResultFuture<List<VehicleEntity>> getVehicles() async {
    try {
      debugPrint('🔄 Getting all vehicles from remote');
      final remoteVehicles = await _remoteDatasource.getVehicles();
      debugPrint('✅ Successfully retrieved ${remoteVehicles.length} vehicles');
      return Right(remoteVehicles);
    } on ServerException catch (e) {
      debugPrint('❌ Server error getting vehicles: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<VehicleEntity> loadVehicleByDeliveryTeam(String deliveryTeamId) async {
    try {
      debugPrint('🔄 Loading vehicle for delivery team: $deliveryTeamId');
      final remoteVehicle = await _remoteDatasource.loadVehicleByDeliveryTeam(deliveryTeamId);
      debugPrint('✅ Successfully loaded vehicle for delivery team');
      return Right(remoteVehicle);
    } on ServerException catch (e) {
      debugPrint('❌ Server error loading vehicle by delivery team: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<VehicleEntity> loadVehicleByTripId(String tripId) async {
    try {
      debugPrint('🔄 Loading vehicle for trip: $tripId');
      final remoteVehicle = await _remoteDatasource.loadVehicleByTripId(tripId);
      debugPrint('✅ Successfully loaded vehicle for trip');
      return Right(remoteVehicle);
    } on ServerException catch (e) {
      debugPrint('❌ Server error loading vehicle by trip: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<VehicleEntity> createVehicle({
    required String vehicleName,
    required String vehiclePlateNumber,
    required String vehicleType,
    String? deliveryTeamId,
    String? tripId,
  }) async {
    try {
      debugPrint('🔄 Creating new vehicle: $vehicleName');
      final createdVehicle = await _remoteDatasource.createVehicle(
        vehicleName: vehicleName,
        vehiclePlateNumber: vehiclePlateNumber,
        vehicleType: vehicleType,
        deliveryTeamId: deliveryTeamId,
        tripId: tripId,
      );
      debugPrint('✅ Successfully created vehicle with ID: ${createdVehicle.id}');
      return Right(createdVehicle);
    } on ServerException catch (e) {
      debugPrint('❌ Server error creating vehicle: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<VehicleEntity> updateVehicle({
    required String vehicleId,
    String? vehicleName,
    String? vehiclePlateNumber,
    String? vehicleType,
    String? deliveryTeamId,
    String? tripId,
  }) async {
    try {
      debugPrint('🔄 Updating vehicle: $vehicleId');
      final updatedVehicle = await _remoteDatasource.updateVehicle(
        vehicleId: vehicleId,
        vehicleName: vehicleName,
        vehiclePlateNumber: vehiclePlateNumber,
        vehicleType: vehicleType,
        deliveryTeamId: deliveryTeamId,
        tripId: tripId,
      );
      debugPrint('✅ Successfully updated vehicle');
      return Right(updatedVehicle);
    } on ServerException catch (e) {
      debugPrint('❌ Server error updating vehicle: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<bool> deleteVehicle(String vehicleId) async {
    try {
      debugPrint('🔄 Deleting vehicle: $vehicleId');
      final result = await _remoteDatasource.deleteVehicle(vehicleId);
      debugPrint('✅ Successfully deleted vehicle');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting vehicle: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<bool> deleteAllVehicles(List<String> vehicleIds) async {
    try {
      debugPrint('🔄 Deleting multiple vehicles: ${vehicleIds.length} items');
      final result = await _remoteDatasource.deleteAllVehicles(vehicleIds);
      debugPrint('✅ Successfully deleted all vehicles');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting multiple vehicles: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
