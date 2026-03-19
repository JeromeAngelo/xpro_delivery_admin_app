import 'package:equatable/equatable.dart';

class DeliveryStatusChoicesEntity extends Equatable {

  String? id;
  String? collectionId;
  String? collectionName;
  String? title;
  String? subtitle;
  DateTime? created;
  DateTime? updated;

  DeliveryStatusChoicesEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.title,
    this.subtitle,
    this.created,
    this.updated,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    title,
    subtitle,
    created,
    updated,
  ];
}