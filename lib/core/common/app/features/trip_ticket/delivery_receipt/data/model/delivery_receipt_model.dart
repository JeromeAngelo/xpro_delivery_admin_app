import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../../../typedefs/typedefs.dart';
import '../../../trip/data/models/trip_models.dart';
import '../../../trip/domain/entity/trip_entity.dart' show TripEntity;
import '../../../delivery_data/data/model/delivery_data_model.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';
import '../../domain/entity/delivery_receipt_entity.dart';


class DeliveryReceiptModel extends DeliveryReceiptEntity {
  String pocketbaseId;

  DeliveryReceiptModel({
    super.id,
    super.collectionId,
    super.collectionName,
    TripModel? trip,
    DeliveryDataModel? deliveryData,
    super.status,
    super.dateTimeCompleted,
    super.customerImages,
    super.customerSignature,
    super.receiptFile,
    super.created,
    super.updated,
  }) : 
    pocketbaseId = id ?? '',
    super(
      trip: trip,
      deliveryData: deliveryData,
    );

  factory DeliveryReceiptModel.fromJson(DataMap json) {
    debugPrint('🔧 DeliveryReceiptModel.fromJson: Processing delivery receipt data');
    debugPrint('📋 Raw JSON keys: ${json.keys.toList()}');
    debugPrint('📋 Delivery Receipt ID from JSON: ${json['id']}');
    debugPrint('📋 Status from JSON: ${json['status']}');

    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Parse customer images list
    List<String>? parseCustomerImages(dynamic value) {
      if (value == null) return null;
      
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      } else if (value is String && value.isNotEmpty) {
        // Handle comma-separated string format
        return value.split(',').where((s) => s.trim().isNotEmpty).toList();
      }
      
      return null;
    }

    // Handle expanded data for relations
    final expandedData = json['expand'] as Map<String, dynamic>?;
    
    // Process trip relation
    TripModel? tripModel;
    if (expandedData != null && expandedData.containsKey('trip')) {
      final tripData = expandedData['trip'];
      if (tripData != null) {
        if (tripData is RecordModel) {
          tripModel = TripModel.fromJson({
            'id': tripData.id,
            'collectionId': tripData.collectionId,
            'collectionName': tripData.collectionName,
            ...tripData.data,
            'expand': tripData.expand,
          });
        } else if (tripData is Map) {
          tripModel = TripModel.fromJson(tripData as DataMap);
        }
      }
    } else if (json['trip'] != null) {
      // If not expanded, just store the ID
      tripModel = TripModel(id: json['trip'].toString());
    }
    
    // Process deliveryData relation
    DeliveryDataModel? deliveryDataModel;
    if (expandedData != null && expandedData.containsKey('deliveryData')) {
      final deliveryDataData = expandedData['deliveryData'];
      if (deliveryDataData != null) {
        if (deliveryDataData is RecordModel) {
          deliveryDataModel = DeliveryDataModel.fromJson({
            'id': deliveryDataData.id,
            'collectionId': deliveryDataData.collectionId,
            'collectionName': deliveryDataData.collectionName,
            ...deliveryDataData.data,
            'expand': deliveryDataData.expand,
          });
        } else if (deliveryDataData is Map) {
          deliveryDataModel = DeliveryDataModel.fromJson(deliveryDataData as DataMap);
        }
      }
    } else if (json['deliveryData'] != null) {
      // If not expanded, just store the ID
      deliveryDataModel = DeliveryDataModel(id: json['deliveryData'].toString());
    }

    debugPrint('🔗 Relations summary for delivery receipt ${json['id']}:');
    debugPrint('   - Trip: ${tripModel?.id ?? "null"}');
    debugPrint('   - DeliveryData: ${deliveryDataModel?.id ?? "null"}');
    debugPrint('   - Status: ${json['status']}');
    debugPrint('   - Customer Images: ${parseCustomerImages(json['customerImages'])?.length ?? 0}');
    debugPrint('   - Has Signature: ${json['customerSignature'] != null}');
    debugPrint('   - Has Receipt: ${json['receiptFile'] != null}');

    return DeliveryReceiptModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      status: json['status']?.toString(),
      dateTimeCompleted: parseDate(json['dateTimeCompleted']),
      customerImages: parseCustomerImages(json['customerImages']),
      customerSignature: json['customerSignature']?.toString(),
      receiptFile: json['receiptFile']?.toString(),
      trip: tripModel,
      deliveryData: deliveryDataModel,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'status': status,
      'dateTimeCompleted': dateTimeCompleted?.toIso8601String(),
      'customerImages': customerImages, // Will be serialized as JSON array
      'customerSignature': customerSignature,
      'receiptFile': receiptFile,
      'trip': trip?.id,
      'deliveryData': deliveryData?.id,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  factory DeliveryReceiptModel.fromEntity(DeliveryReceiptEntity entity) {
    return DeliveryReceiptModel(
      id: entity.id,
      collectionId: entity.collectionId,
      collectionName: entity.collectionName,
      status: entity.status,
      dateTimeCompleted: entity.dateTimeCompleted,
      customerImages: entity.customerImages,
      customerSignature: entity.customerSignature,
      receiptFile: entity.receiptFile,
      created: entity.created,
      updated: entity.updated,
    );
  }

  @override
  DeliveryReceiptModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    TripEntity? trip,
    DeliveryDataEntity? deliveryData,
    String? status,
    DateTime? dateTimeCompleted,
    List<String>? customerImages,
    String? customerSignature,
    String? receiptFile,
    DateTime? created,
    DateTime? updated,
  }) {
    return DeliveryReceiptModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      trip: trip != null 
          ? (trip is TripModel 
              ? trip 
              : TripModel(id: trip.id))
          : (this.trip is TripModel 
              ? this.trip as TripModel 
              : this.trip != null 
                  ? TripModel(id: this.trip!.id)
                  : null),
      deliveryData: deliveryData != null 
          ? (deliveryData is DeliveryDataModel 
              ? deliveryData 
              : DeliveryDataModel(id: deliveryData.id))
          : (this.deliveryData is DeliveryDataModel 
              ? this.deliveryData as DeliveryDataModel 
              : this.deliveryData != null 
                  ? DeliveryDataModel(id: this.deliveryData!.id)
                  : null),
      status: status ?? this.status,
      dateTimeCompleted: dateTimeCompleted ?? this.dateTimeCompleted,
      customerImages: customerImages ?? this.customerImages,
      customerSignature: customerSignature ?? this.customerSignature,
      receiptFile: receiptFile ?? this.receiptFile,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory DeliveryReceiptModel.empty() {
    return DeliveryReceiptModel(
      id: '',
      collectionId: '',
      collectionName: '',
      trip: null,
      deliveryData: null,
      status: '',
      dateTimeCompleted: null,
      customerImages: [],
      customerSignature: '',
      receiptFile: '',
      created: DateTime.now(),
      updated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryReceiptModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeliveryReceiptModel('
        'id: $id, '
        'trip: ${trip?.id}, '
        'deliveryData: ${deliveryData?.id}, '
        'status: $status, '
        'dateTimeCompleted: $dateTimeCompleted, '
        'customerImages: ${customerImages?.length ?? 0}, '
        'customerSignature: $customerSignature, '
        'receiptFile: $receiptFile'
        ')';
  }
}
