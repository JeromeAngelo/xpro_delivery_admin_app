import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
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
  String? totalTime;
  bool? hasNotes;
  double? confirmedTotalPayment;
  String? notes;
  String? remarks;
  final List<TransactionModel> transactionList;
  final List<TransactionModel> transactions;

  final List<ReturnModel> returnList;
  final List<ReturnModel> returns;

  final List<InvoiceModel> invoicesList;
  final List<InvoiceModel> invoices;

  final List<DeliveryUpdateModel> deliveryStatus;

  final TripModel? trip;

  String? modeOfPaymentString;

  ModeOfPayment get paymentSelection => ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

  int? numberOfInvoices;
String? totalAmount;
  String? latitude;
  String? longitude;
  DateTime? created;
  DateTime? updated;

  CustomerEntity({
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
    this.totalTime,
    List<DeliveryUpdateModel>? deliveryStatusList,
    this.numberOfInvoices,
    this.totalAmount,
    List<InvoiceModel>? invoicesList,
    TripModel? tripModel,
    this.confirmedTotalPayment,
    this.hasNotes,
    this.latitude,
    this.longitude,
    this.created,
    this.updated,
    this.notes,
    this.remarks,
    this.modeOfPaymentString,
    List<ReturnModel>? returnList,
    List<TransactionModel>? transactionList,
  })  : invoicesList = invoicesList ?? [],
        returnList = returnList ?? [],
        transactionList = transactionList ?? [],
        invoices = invoicesList ?? [],
        returns = returnList ?? [],
        transactions = transactionList ?? [],
        deliveryStatus = deliveryStatusList ?? [],
        trip = tripModel;

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
        deliveryStatus,
        numberOfInvoices,
        totalAmount,
        invoicesList,
        invoices,
        trip?.id,
        latitude,
        longitude,
        created,
        updated,
        returnList,
        transactionList,
        totalTime,
        notes,
        remarks,
        modeOfPaymentString,
        hasNotes,
        confirmedTotalPayment
      ];
}
