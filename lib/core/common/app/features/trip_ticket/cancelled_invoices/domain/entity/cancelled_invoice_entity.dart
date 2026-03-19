import 'package:equatable/equatable.dart';

import '../../../../../../../enums/undeliverable_reason.dart';
import '../../../trip/domain/entity/trip_entity.dart';
import '../../../customer_data/domain/entity/customer_data_entity.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';
import '../../../invoice_data/domain/entity/invoice_data_entity.dart';


class CancelledInvoiceEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;

  // Relations - using entities instead of models
  final DeliveryDataEntity? deliveryData;
  final TripEntity? trip;
  final CustomerDataEntity? customer;
  final InvoiceDataEntity? invoice;

  final UndeliverableReason? reason;
  final String? image;

  // Standard fields
  final DateTime? created;
  final DateTime? updated;

  const CancelledInvoiceEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.deliveryData,
    this.trip,
    this.customer,
    this.invoice,
    this.reason,
    this.image,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    deliveryData?.id,
    trip?.id,
    customer?.id,
    invoice?.id,
    reason,
    image,
    created,
    updated,
  ];

  // Factory constructor for creating an empty entity
  factory CancelledInvoiceEntity.empty() {
    return const CancelledInvoiceEntity(
      id: '',
      collectionId: '',
      collectionName: '',
      deliveryData: null,
      trip: null,
      customer: null,
      invoice: null,
      reason: UndeliverableReason.none,
      image: '',
      created: null,
      updated: null,
    );
  }

  // CopyWith method for immutable updates
  CancelledInvoiceEntity copyWith({
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
    return CancelledInvoiceEntity(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      deliveryData: deliveryData ?? this.deliveryData,
      trip: trip ?? this.trip,
      customer: customer ?? this.customer,
      invoice: invoice ?? this.invoice,
      reason: reason ?? this.reason,
      image: image ?? this.image,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'CancelledInvoiceEntity('
        'id: $id, '
        'collectionId: $collectionId, '
        'collectionName: $collectionName, '
        'deliveryData: ${deliveryData?.id}, '
        'trip: ${trip?.id}, '
        'customer: ${customer?.id}, '
        'invoice: ${invoice?.id}, '
        'reason: $reason, '
        'image: $image, '
        'created: $created, '
        'updated: $updated'
        ')';
  }
}
