import 'package:flutter/material.dart' show debugPrint;
import 'package:pocketbase/pocketbase.dart';

import '../../../../../../../errors/exceptions.dart';
import '../../model/delivery_status_choices_model.dart';

abstract class DeliveryStatusChoicesRemoteDatasource {

  Future<List<DeliveryStatusChoicesModel>> getAllAssignedDeliveryStatusChoices(
    String customerId,
  );

   Future<String> updateCustomerStatus(
    String deliveryDataId, // DeliveryData PB ID
    DeliveryStatusChoicesModel status, // ✅ FULL MODEL
  );
}

class DeliveryStatusChoicesRemoteDatasourceImpl
    implements DeliveryStatusChoicesRemoteDatasource {
    final PocketBase _pocketBaseClient;

  const DeliveryStatusChoicesRemoteDatasourceImpl(this._pocketBaseClient);
  
 @override
  Future<List<DeliveryStatusChoicesModel>> getAllAssignedDeliveryStatusChoices(
    String customerId,
  ) async {
    try {
      debugPrint(
        '🚚 Fetching delivery status choices for customer: $customerId',
      );

      final customerRecord = await _pocketBaseClient
          .collection('deliveryData')
          .getOne(customerId, expand: 'deliveryUpdates');

      final deliveryUpdates = customerRecord.expand['deliveryUpdates'] as List?;
      final latestStatus =
          deliveryUpdates?.isNotEmpty == true
              ? deliveryUpdates!.last.data['title'].toString().toLowerCase()
              : '';

      debugPrint('📍 Latest status for customer $customerId: $latestStatus');

      final allStatuses =
          await _pocketBaseClient
              .collection('deliveryStatusChoices')
              .getFullList();

      // Log available status choices
      for (var status in allStatuses) {
        debugPrint(
          '🏷️ Available Status - ID: ${status.id}, Title: ${status.data['title']}',
        );
      }

      // Apply status rules
      final allowedTitles = <String>[];
      switch (latestStatus) {
       
        case 'invoices in queue':
          allowedTitles.addAll(['arrived', 'in transit']);
          break;
        case 'unloading':
          allowedTitles.addAll(['arrived', 'waiting for customer']);
          break;
        case 'mark as received':
          allowedTitles.addAll(['unloading']);
          break;
        case 'arrived':
          allowedTitles.addAll([
            'in transit',
          ]);
          break;
        case 'mark as undelivered':
        allowedTitles.addAll(['arrived', 'in transit']);
          break;
        case 'end delivery':
        allowedTitles.addAll(['mark as undelivered']);
          break;
        default:  
          return [];
      }

      final assignedTitles =
          deliveryUpdates
              ?.map((record) => record.data['title'].toString().toLowerCase())
              .toSet() ??
          {};

      debugPrint('📋 Already assigned titles: $assignedTitles');

      // Filter allowed and not assigned yet
      final filteredStatuses =
          allStatuses
              .where(
                (status) => allowedTitles.contains(
                  status.data['title'].toString().toLowerCase(),
                ),
              )
              .where(
                (status) =>
                    !assignedTitles.contains(
                      status.data['title'].toString().toLowerCase(),
                    ),
              )
              .map((record) {
                final statusId = record.id;
                debugPrint(
                  '🏷️ Processing status - ID: $statusId, Title: ${record.data['title']}',
                );

                return DeliveryStatusChoicesModel(
                  id: statusId,
                  title: record.data['title'],
                  subtitle: record.data['subtitle'],
                  collectionId: record.collectionId,
                  collectionName: record.collectionName,
                );
              })
              .toList();

      return filteredStatuses;
    } catch (e) {
      debugPrint('❌ Error fetching delivery status choices: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch delivery status choices: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<String> updateCustomerStatus(
    String deliveryDataId,
    DeliveryStatusChoicesModel status,
  ) async {
    try {
      debugPrint(
        '🔄 Processing status update - DeliveryData: $deliveryDataId, '
        'Status: ${status.title} (${status.id})',
      );

      // ---------------------------------------------------
      // 0️⃣ VALIDATE
      // ---------------------------------------------------
      if (status.id!.isEmpty) {
        debugPrint('⚠️ Invalid status PB ID provided');
        throw const ServerException(
          message: 'Invalid status ID',
          statusCode: '400',
        );
      }

      // ---------------------------------------------------
      // 1️⃣ CREATE DeliveryUpdate (COPY DATA)
      // ---------------------------------------------------
      final currentTime = DateTime.now().toIso8601String();

      final deliveryUpdateRecord = await _pocketBaseClient
          .collection('deliveryUpdate')
          .create(
            body: {
              'deliveryData': deliveryDataId,
              'status': status.id, // 🔑 PB relation
              'title': status.title, // 📋 copied
              'subtitle': status.subtitle, // 📋 copied
              'created': currentTime,
              'time': currentTime,
              'isAssigned': true,
            },
          );

      debugPrint('📝 Created delivery update: ${deliveryUpdateRecord.id}');

      // ---------------------------------------------------
      // 2️⃣ ATTACH DeliveryUpdate → DeliveryData
      // ---------------------------------------------------
      await _pocketBaseClient
          .collection('deliveryData')
          .update(
            deliveryDataId,
            body: {
              'deliveryUpdates+': [deliveryUpdateRecord.id],
            },
          );

      debugPrint('✅ Successfully updated deliveryData');

      // ---------------------------------------------------
      // 3️⃣ CREATE NOTIFICATION (REMOTE ONLY)
      // ---------------------------------------------------
      final deliveryDataRecord = await _pocketBaseClient
          .collection('deliveryData')
          .getOne(deliveryDataId);

      final tripId = deliveryDataRecord.data['trip'];

      debugPrint('📦 Found trip for notification: $tripId');

      await _pocketBaseClient
          .collection('notifications')
          .create(
            body: {
              'delivery': deliveryDataRecord.id,
              'status': deliveryUpdateRecord.id,
              'trip': tripId,
              'type': 'deliveryUpdate',
              'created': currentTime,
            },
          );

      debugPrint('✅ Successfully created notification');

      // Return created delivery update id to caller so local records can be reconciled
      return deliveryUpdateRecord.id;
    } catch (e) {
      debugPrint('❌ Operation failed: ${e.toString()}');
      throw ServerException(
        message:
            e is ServerException
                ? e.message
                : 'Operation failed: ${e.toString()}',
        statusCode: e is ServerException ? e.statusCode : '500',
      );
    }
  }

}