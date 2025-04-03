import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:equatable/equatable.dart';

abstract class ReturnEvent extends Equatable { 
  const ReturnEvent();

  @override
  List<Object?> get props => [];
}

// Existing events
class GetReturnsEvent extends ReturnEvent {
  final String tripId;
  const GetReturnsEvent(this.tripId);

  @override
  List<Object> get props => [tripId];
}

class GetReturnByCustomerIdEvent extends ReturnEvent {
  final String customerId;
  const GetReturnByCustomerIdEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}

// New events for CRUD operations
class GetAllReturnsEvent extends ReturnEvent {
  const GetAllReturnsEvent();
}

class CreateReturnEvent extends ReturnEvent {
  final String productName;
  final String productDescription;
  final ProductReturnReason reason;
  final DateTime returnDate;
  final int? productQuantityCase;
  final int? productQuantityPcs;
  final int? productQuantityPack;
  final int? productQuantityBox;
  final bool? isCase;
  final bool? isPcs;
  final bool? isBox;
  final bool? isPack;
  final String? invoiceId;
  final String? customerId;
  final String? tripId;

  const CreateReturnEvent({
    required this.productName,
    required this.productDescription,
    required this.reason,
    required this.returnDate,
    required this.productQuantityCase,
    required this.productQuantityPcs,
    required this.productQuantityPack,
    required this.productQuantityBox,
    required this.isCase,
    required this.isPcs,
    required this.isBox,
    required this.isPack,
    this.invoiceId,
    this.customerId,
    this.tripId,
  });

  @override
  List<Object?> get props => [
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
    invoiceId,
    customerId,
    tripId,
  ];
}

class UpdateReturnEvent extends ReturnEvent {
  final String id;
  final String? productName;
  final String? productDescription;
  final ProductReturnReason? reason;
  final DateTime? returnDate;
  final int? productQuantityCase;
  final int? productQuantityPcs;
  final int? productQuantityPack;
  final int? productQuantityBox;
  final bool? isCase;
  final bool? isPcs;
  final bool? isBox;
  final bool? isPack;
  final String? invoiceId;
  final String? customerId;
  final String? tripId;

  const UpdateReturnEvent({
    required this.id,
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
    this.invoiceId,
    this.customerId,
    this.tripId,
  });

  @override
  List<Object?> get props => [
    id,
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
    invoiceId,
    customerId,
    tripId,
  ];
}

class DeleteReturnEvent extends ReturnEvent {
  final String id;
  
  const DeleteReturnEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class DeleteAllReturnsEvent extends ReturnEvent {
  final List<String> ids;
  
  const DeleteAllReturnsEvent(this.ids);
  
  @override
  List<Object> get props => [ids];
}
