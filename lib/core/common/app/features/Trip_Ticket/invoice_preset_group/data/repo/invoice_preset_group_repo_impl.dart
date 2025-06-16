import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/data/datasources/remote_datasource/invoice_preset_group_remote_data_src.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/entity/invoice_preset_group_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/repo/invoice_preset_group_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class InvoicePresetGroupRepoImpl implements InvoicePresetGroupRepo {
  const InvoicePresetGroupRepoImpl(this._remoteDataSource);

  final InvoicePresetGroupRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<InvoicePresetGroupEntity>>
  getAllInvoicePresetGroups() async {
    try {
      debugPrint('🌐 Fetching all invoice preset groups from remote');
      final remotePresetGroups =
          await _remoteDataSource.getAllInvoicePresetGroups();
      debugPrint(
        '✅ Retrieved ${remotePresetGroups.length} invoice preset groups',
      );
      return Right(remotePresetGroups);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> addAllInvoicesToDelivery({
    required String presetGroupId,
    required String deliveryId,
  }) async {
    try {
      debugPrint(
        '🌐 Adding invoices from preset group $presetGroupId to delivery $deliveryId',
      );
      await _remoteDataSource.addAllInvoicesToDelivery(
        presetGroupId: presetGroupId,
        deliveryId: deliveryId,
      );
      debugPrint('✅ Successfully added invoices to delivery');
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<InvoicePresetGroupEntity>> searchPresetGroupByRefId(
    String refId,
  ) async {
    try {
      debugPrint('🌐 Searching invoice preset groups with refId: $refId');
      final remotePresetGroups = await _remoteDataSource
          .searchPresetGroupByRefId(refId);
      debugPrint(
        '✅ Found ${remotePresetGroups.length} invoice preset groups matching refId: $refId',
      );
      return Right(remotePresetGroups);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<InvoicePresetGroupEntity>>
  getAllUnassignedInvoicePresetGroups() async {
    try {
      debugPrint(
        '🌐 Fetching all unassigned invoice preset groups from remote',
      );

      final remoteUnassignedPresetGroups =
          await _remoteDataSource.getAllUnassignedInvoicePresetGroups();
      debugPrint(
        '✅ Retrieved ${remoteUnassignedPresetGroups.length} invoice preset groups',
      );

      return Right(remoteUnassignedPresetGroups);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');

      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
