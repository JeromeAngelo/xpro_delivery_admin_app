import 'package:equatable/equatable.dart';

class DeliveryUpdateEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  String? title;
  String? subtitle;
  DateTime? time;
  DateTime? created;
  DateTime? updated;
  String? customer;
  String? image;
  bool? isAssigned;
  String? assignedTo;
  String? remarks;

  DeliveryUpdateEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.title,
    this.subtitle,
    this.time,
    this.created,
    this.updated,
    this.customer,
    this.remarks,
    this.image,
    this.isAssigned,
    this.assignedTo,
  }) ;

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        title,
        subtitle,
        time,
        created,
        updated,
        remarks,
        customer,
        isAssigned,
        assignedTo,
        image,
      ];
}
