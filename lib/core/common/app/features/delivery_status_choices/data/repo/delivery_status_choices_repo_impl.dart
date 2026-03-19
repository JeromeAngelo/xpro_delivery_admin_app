import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/delivery_status_choices/domain/entity/delivery_status_choices_entity.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../../../../../errors/failures.dart';
import '../../domain/repo/delivery_status_choices_repo.dart';
import '../datasource/remote_datasource/delivery_status_choices_remote_datasource.dart';
import '../model/delivery_status_choices_model.dart';

class DeliveryStatusChoicesRepoImpl implements DeliveryStatusChoicesRepo {
  final DeliveryStatusChoicesRemoteDatasource _remoteDatasource;
  DeliveryStatusChoicesRepoImpl(
    this._remoteDatasource,
  );

  @override
  ResultFuture<List<DeliveryStatusChoicesEntity>> getAllAssignedDeliveryStatusChoices(String customerId) async{
    try {
      debugPrint('📦 Fetching assigned delivery status choices for customer: $customerId');
      final assignedStatus = await _remoteDatasource.getAllAssignedDeliveryStatusChoices(customerId);
      debugPrint('✅ Successfully fetched assigned delivery status choices for customer: $customerId');
      return Right(assignedStatus);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to fetch assigned delivery status choices for customer: $customerId');
      return Left(ServerFailure(message:e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ Unexpected error while fetching assigned delivery status choices for customer: $customerId - ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<void> updateDeliveryStatus(String deliveryDataId, DeliveryStatusChoicesEntity status) async {
   try {
      final statusModel = status as DeliveryStatusChoicesModel;
      await _remoteDatasource.updateCustomerStatus(deliveryDataId, statusModel);
      debugPrint('✅ Successfully updated delivery status for delivery data: $deliveryDataId');
      return Right(null);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to update delivery status for delivery data: $deliveryDataId');
      return Left(ServerFailure(message:e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ Unexpected error while updating delivery status for delivery data: $deliveryDataId - ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
