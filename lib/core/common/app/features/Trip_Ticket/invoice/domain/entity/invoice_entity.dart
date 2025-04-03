import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/data/model/product_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart' show TripModel;
import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:equatable/equatable.dart';


class InvoiceEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  String? invoiceNumber;
  
  final List<ProductModel> productsList;
  final List<ProductModel> productList;
  
  InvoiceStatus? status;
  
  final CustomerModel? customer;
  final TripModel? trip;
  
  double? totalAmount;
  double? confirmTotalAmount;
  String? customerDeliveryStatus;
  DateTime? created;
  DateTime? updated;

  InvoiceEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.invoiceNumber,
    List<ProductModel>? productsList,
    this.status,
    this.customer,
    this.trip,
    this.totalAmount,
    this.confirmTotalAmount,
    this.customerDeliveryStatus,
    this.created,
    this.updated,
  }) : 
    productsList = productsList ?? [],
    productList = productsList ?? [];

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        invoiceNumber,
        productList,
        status,
        customer?.id,
        trip?.id,
        totalAmount,
        confirmTotalAmount,
        customerDeliveryStatus,
        created,
        updated,
      ];
}
