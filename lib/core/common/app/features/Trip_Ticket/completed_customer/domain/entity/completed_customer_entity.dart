import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:equatable/equatable.dart';


class CompletedCustomerEntity extends Equatable {
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
  DateTime? timeCompleted;
  double? totalAmount;
  String? totalTime;
  final List<InvoiceModel> invoicesList;
  final List<InvoiceModel> invoices;
  
  final List<DeliveryUpdateModel> deliveryStatus;
  final TripModel? trip;

  final TransactionModel? transaction;
  final TransactionModel? transactionRef;

  final List<ReturnModel> returnList;
  final List<ReturnModel> returns;

  final CustomerModel? customer;
  final CustomerModel? customerRef;

  String? modeOfPaymentString;
    
  ModeOfPayment get paymentSelection => ModeOfPayment.values.firstWhere(
    (mode) => mode.toString() == modeOfPaymentString,
    orElse: () => ModeOfPayment.cashOnDelivery,
  );

  CompletedCustomerEntity({
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
    this.timeCompleted,
    this.totalAmount,
    this.totalTime,
    this.modeOfPaymentString,
    List<InvoiceModel>? invoicesList,
    this.transaction,
    List<ReturnModel>? returnList,
    this.customer,
    List<DeliveryUpdateModel>? deliveryStatusList,
    TripModel? tripModel,
    this.transactionRef,
    this.customerRef,
  }) : invoicesList = invoicesList ?? [],
       returnList = returnList ?? [],
       invoices = invoicesList ?? [],
       returns = returnList ?? [],
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
    timeCompleted,
    totalAmount,
    invoicesList,
    invoices,
    deliveryStatus,
    trip?.id,
    transaction,
    transactionRef,
    returnList,
    returns,
    customer,
    customerRef,
    modeOfPaymentString,
  ];
}
