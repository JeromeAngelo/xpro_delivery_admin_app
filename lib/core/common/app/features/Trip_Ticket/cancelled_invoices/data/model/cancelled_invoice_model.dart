import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart' show TripEntity;

import '../../../../../../../enums/undeliverable_reason.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../trip/data/models/trip_models.dart';
import '../../../customer_data/data/model/customer_data_model.dart';
import '../../../customer_data/domain/entity/customer_data_entity.dart';
import '../../../delivery_data/data/model/delivery_data_model.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';
import '../../../invoice_data/data/model/invoice_data_model.dart';
import '../../../invoice_data/domain/entity/invoice_data_entity.dart';
import '../../domain/entity/cancelled_invoice_entity.dart';


class CancelledInvoiceModel extends CancelledInvoiceEntity {
  String pocketbaseId;

  CancelledInvoiceModel({
    super.id,
    super.collectionId,
    super.collectionName,
    DeliveryDataModel? deliveryData,
    TripModel? trip,
    CustomerDataModel? customer,
    InvoiceDataModel? invoice,
    super.reason,
    super.image,
    super.created,
    super.updated,
  }) : 
    pocketbaseId = id ?? '',
    super(
      deliveryData: deliveryData,
      trip: trip,
      customer: customer,
      invoice: invoice,
    );

  factory CancelledInvoiceModel.fromJson(DataMap json) {
    debugPrint('🔧 CancelledInvoiceModel.fromJson: Processing cancelled invoice data');
    debugPrint('📋 Raw JSON keys: ${json.keys.toList()}');
    debugPrint('📋 Cancelled Invoice ID from JSON: ${json['id']}');
    debugPrint('📋 Reason from JSON: ${json['reason']}');

    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Parse UndeliverableReason enum
    UndeliverableReason? parseReason(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        final reasonString = value.toString().toLowerCase();
        return UndeliverableReason.values.firstWhere(
          (reason) => reason.toString().split('.').last.toLowerCase() == reasonString,
          orElse: () => UndeliverableReason.none,
        );
      } catch (_) {
        return UndeliverableReason.none;
      }
    }

    // Handle expanded data for relations
    final expandedData = json['expand'] as Map<String, dynamic>?;
    
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

    // Process customer relation
    CustomerDataModel? customerModel;
    if (expandedData != null && expandedData.containsKey('customer')) {
      final customerData = expandedData['customer'];
      if (customerData != null) {
        if (customerData is RecordModel) {
          customerModel = CustomerDataModel.fromJson({
            'id': customerData.id,
            'collectionId': customerData.collectionId,
            'collectionName': customerData.collectionName,
            ...customerData.data,
            'expand': customerData.expand,
          });
        } else if (customerData is Map) {
          customerModel = CustomerDataModel.fromJson(customerData as DataMap);
        }
      }
    } else if (json['customer'] != null) {
      // If not expanded, just store the ID
      customerModel = CustomerDataModel(id: json['customer'].toString());
    }

    // Process invoice relation
    InvoiceDataModel? invoiceModel;
    if (expandedData != null && expandedData.containsKey('invoice')) {
      final invoiceData = expandedData['invoice'];
      if (invoiceData != null) {
        if (invoiceData is RecordModel) {
          invoiceModel = InvoiceDataModel.fromJson({
            'id': invoiceData.id,
            'collectionId': invoiceData.collectionId,
            'collectionName': invoiceData.collectionName,
            ...invoiceData.data,
            'expand': invoiceData.expand,
          });
        } else if (invoiceData is Map) {
          invoiceModel = InvoiceDataModel.fromJson(invoiceData as DataMap);
        }
      }
    } else if (json['invoice'] != null) {
      // If not expanded, just store the ID
      invoiceModel = InvoiceDataModel(id: json['invoice'].toString());
    }

    debugPrint('🔗 Relations summary for cancelled invoice ${json['id']}:');
    debugPrint('   - DeliveryData: ${deliveryDataModel?.id ?? "null"}');
    debugPrint('   - Trip: ${tripModel?.id ?? "null"}');
    debugPrint('   - Customer: ${customerModel?.id ?? "null"} (${customerModel?.name ?? "null"})');
    debugPrint('   - Invoice: ${invoiceModel?.id ?? "null"} (${invoiceModel?.refId ?? "null"})');
    debugPrint('   - Reason: ${parseReason(json['reason'])}');

    return CancelledInvoiceModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      reason: parseReason(json['reason']),
      image: json['image']?.toString(),
      deliveryData: deliveryDataModel,
      trip: tripModel,
      customer: customerModel,
      invoice: invoiceModel,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'reason': reason?.toString().split('.').last,
      'image': image,
      'deliveryData': deliveryData?.id,
      'trip': trip?.id,
      'customer': customer?.id,
      'invoice': invoice?.id,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  factory CancelledInvoiceModel.fromEntity(CancelledInvoiceEntity entity) {
    return CancelledInvoiceModel(
      id: entity.id,
      collectionId: entity.collectionId,
      collectionName: entity.collectionName,
      reason: entity.reason,
      image: entity.image,
      created: entity.created,
      updated: entity.updated,
    );
  }

  @override
  CancelledInvoiceModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    DeliveryDataEntity? deliveryData,
    TripEntity? trip,
    CustomerDataEntity? customer,
    InvoiceDataEntity? invoice,
    UndeliverableReason? reason,
    String? image,
    DateTime? created,
    DateTime? updated,
  }) {
    return CancelledInvoiceModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      customer: customer != null 
          ? (customer is CustomerDataModel 
              ? customer 
              : CustomerDataModel(
                  id: customer.id,
                  collectionId: customer.collectionId,
                  collectionName: customer.collectionName,
                  name: customer.name,
                  created: customer.created,
                  updated: customer.updated,
                ))
          : (this.customer is CustomerDataModel 
              ? this.customer as CustomerDataModel 
              : this.customer != null 
                  ? CustomerDataModel(
                      id: this.customer!.id,
                      collectionId: this.customer!.collectionId,
                      collectionName: this.customer!.collectionName,
                      name: this.customer!.name,
                      created: this.customer!.created,
                      updated: this.customer!.updated,
                    )
                  : null),
      invoice: invoice != null 
          ? (invoice is InvoiceDataModel 
              ? invoice 
              : InvoiceDataModel(
                  id: invoice.id,
                  collectionId: invoice.collectionId,
                  collectionName: invoice.collectionName,
                  refId: invoice.refId,
                  name: invoice.name,
                  documentDate: invoice.documentDate,
                  totalAmount: invoice.totalAmount,
                  volume: invoice.volume,
                  weight: invoice.weight,
                  created: invoice.created,
                  updated: invoice.updated,
                  customer: invoice.customer,
                ))
                    : (this.invoice is InvoiceDataModel 
              ? this.invoice as InvoiceDataModel 
              : this.invoice != null 
                  ? InvoiceDataModel(
                      id: this.invoice!.id,
                      collectionId: this.invoice!.collectionId,
                      collectionName: this.invoice!.collectionName,
                      refId: this.invoice!.refId,
                      name: this.invoice!.name,
                      documentDate: this.invoice!.documentDate,
                      totalAmount: this.invoice!.totalAmount,
                      volume: this.invoice!.volume,
                      weight: this.invoice!.weight,
                      created: this.invoice!.created,
                      updated: this.invoice!.updated,
                      customer: this.invoice!.customer,
                    )
                  : null),
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
      reason: reason ?? this.reason,
      image: image ?? this.image,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory CancelledInvoiceModel.empty() {
    return CancelledInvoiceModel(
      id: '',
      collectionId: '',
      collectionName: '',
      deliveryData: null,
      trip: null,
      customer: null,
      invoice: null,
      reason: UndeliverableReason.none,
      image: '',
      created: DateTime.now(),
      updated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelledInvoiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CancelledInvoiceModel('
        'id: $id, '
        'deliveryData: ${deliveryData?.id}, '
        'trip: ${trip?.id}, '
        'customer: ${customer?.id}, '
        'invoice: ${invoice?.id}, '
        'reason: $reason, '
        'image: $image'
        ')';
  }
}

