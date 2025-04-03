import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/enums/undeliverable_reason.dart';
import 'package:equatable/equatable.dart';


class UndeliverableCustomerEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  String? deliveryNumber;
  String? storeName;
  String? ownerName;
  List<String>? contactNumber;
  String? address;
  String? municipality;
  String? province;
  String? modeOfPayment;
  UndeliverableReason? reason;
  DateTime? time;
  DateTime? created;
  DateTime? updated;
  String? customerImage;

  final List<InvoiceModel> invoicesList;
  final List<InvoiceModel> invoices;

  final CustomerModel? customer;
  final CustomerModel? customerRef;

  final TripModel? trip;
  final TripModel? tripRef;

  UndeliverableCustomerEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.deliveryNumber,
    this.storeName,
    this.ownerName,
    this.contactNumber,
    this.address,
    this.municipality,
    this.province,
    this.modeOfPayment,
    List<InvoiceModel>? invoicesList,
    this.customer,
    this.customerRef,
    this.reason,
    this.time,
    this.created,
    this.updated,
    this.customerImage,
    this.trip,
    this.tripRef,
  }) : 
    invoicesList = invoicesList ?? [],
    invoices = invoicesList ?? [];

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        deliveryNumber,
        storeName,
        ownerName,
        contactNumber,
        address,
        municipality,
        province,
        modeOfPayment,
        invoicesList,
        invoices,
        customer,
        customerRef,
        trip,
        tripRef,
        reason,
        time,
        created,
        updated,
        customerImage,
      ];
}
