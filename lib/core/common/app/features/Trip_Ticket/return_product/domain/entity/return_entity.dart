import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:equatable/equatable.dart';


class ReturnEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  String? productName;
  String? productDescription;
  ProductReturnReason? reason;
  DateTime? returnDate;
  
  int? productQuantityCase;
  int? productQuantityPcs;
  int? productQuantityPack;
  int? productQuantityBox;
  
  bool? isCase;
  bool? isPcs;
  bool? isBox;
  bool? isPack;

 

  TripModel? trip;
   TripModel? tripRef;

  ReturnEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.productName,
    this.productDescription,
    this.reason,
    this.returnDate,
    this.productQuantityCase,
    this.productQuantityPcs,
    this.productQuantityPack,
    this.productQuantityBox,
    this.isCase,
    this.isPcs,
    this.isBox,
    this.isPack,
   
    this.trip,
    this.tripRef,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    productName,
    productDescription,
    reason,
    returnDate,
    productQuantityCase,
    productQuantityPcs,
    productQuantityPack,
    productQuantityBox,
    isCase,
    isPcs,
    isBox,
    isPack,
   
    trip,
    tripRef,
  ];
}
