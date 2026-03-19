import 'package:equatable/equatable.dart';

import '../../../trip/domain/entity/trip_entity.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';


class DeliveryReceiptEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;

  // Relations - using entities instead of models
  final TripEntity? trip;
  final DeliveryDataEntity? deliveryData;

  final String? status;
  final DateTime? dateTimeCompleted;

  // File fields
  final List<String>? customerImages; // List of image file paths/URLs
  final String? customerSignature; // PDF or image file path/URL for signature
  final String? receiptFile; // PDF file path/URL for receipt

  // Standard fields
  final DateTime? created;
  final DateTime? updated;

  const DeliveryReceiptEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.trip,
    this.deliveryData,
    this.status,
    this.dateTimeCompleted,
    this.customerImages,
    this.customerSignature,
    this.receiptFile,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    trip?.id,
    deliveryData?.id,
    status,
    dateTimeCompleted,
    customerImages,
    customerSignature,
    receiptFile,
    created,
    updated,
  ];

  // Factory constructor for creating an empty entity
  factory DeliveryReceiptEntity.empty() {
    return const DeliveryReceiptEntity(
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
      created: null,
      updated: null,
    );
  }

  // CopyWith method for immutable updates
  DeliveryReceiptEntity copyWith({
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
    return DeliveryReceiptEntity(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      trip: trip ?? this.trip,
      deliveryData: deliveryData ?? this.deliveryData,
      status: status ?? this.status,
      dateTimeCompleted: dateTimeCompleted ?? this.dateTimeCompleted,
      customerImages: customerImages ?? this.customerImages,
      customerSignature: customerSignature ?? this.customerSignature,
      receiptFile: receiptFile ?? this.receiptFile,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // Helper methods for file management
  bool get hasCustomerImages => customerImages != null && customerImages!.isNotEmpty;
  bool get hasCustomerSignature => customerSignature != null && customerSignature!.isNotEmpty;
  bool get hasReceiptFile => receiptFile != null && receiptFile!.isNotEmpty;
  
  int get customerImagesCount => customerImages?.length ?? 0;
  
  bool get isCompleted => status?.toLowerCase() == 'completed' || dateTimeCompleted != null;
  
  // Validation helpers
  bool get hasAllRequiredFiles => hasCustomerSignature && hasReceiptFile;
  bool get isReadyForCompletion => hasAllRequiredFiles && status != null;

  @override
  String toString() {
    return 'DeliveryReceiptEntity('
        'id: $id, '
        'collectionId: $collectionId, '
        'collectionName: $collectionName, '
        'trip: ${trip?.id}, '
        'deliveryData: ${deliveryData?.id}, '
        'status: $status, '
        'dateTimeCompleted: $dateTimeCompleted, '
        'customerImages: ${customerImages?.length ?? 0}, '
        'customerSignature: $customerSignature, '
        'receiptFile: $receiptFile, '
        'created: $created, '
        'updated: $updated'
        ')';
  }
}
