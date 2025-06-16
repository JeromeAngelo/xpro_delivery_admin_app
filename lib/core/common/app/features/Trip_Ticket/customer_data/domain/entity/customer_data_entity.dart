import 'package:equatable/equatable.dart';

class CustomerDataEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? name;
  final String? ownerName;
  final String? paymentMode;
  final String? refId;
  final String? province;
  final String? municipality;
  final String? barangay;
  final String? contactNumber;
  final double? longitude;
  final double? latitude;
  final DateTime? created;
  final DateTime? updated;

  const CustomerDataEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.name,
    this.refId,
    this.ownerName,
    this.paymentMode,
    this.province,
    this.municipality,
    this.contactNumber,
    this.barangay,
    this.longitude,
    this.latitude,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    name,
    refId,
    province,
    municipality,
    contactNumber,
    ownerName,
    paymentMode,
    barangay,
    longitude,
    latitude,
    created,
    updated,
  ];
}
