import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/data/models/completed_customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:xpro_delivery_admin_app/core/enums/transaction_status.dart';
import 'package:equatable/equatable.dart';


import 'dart:io';

class TransactionEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  String? customerName;
  String? totalAmount;
  String? refNumber;
  File? signature;
  String? customerImage;
  final List<InvoiceModel> invoices;
  String? deliveryNumber;
  DateTime? transactionDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isCompleted;
  File? pdf;

  String? transactionStatusString;
  String? modeOfPaymentString;

  final TripModel? trip;
  final TripModel? tripRef;

  // Enhanced customer relation
  final CustomerModel? customerModel;
  final CustomerModel? customer;

  // Add completed customer relation
  final CompletedCustomerModel? completedCustomer;
  final CompletedCustomerModel? completedCustomerRef;

  TransactionEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.customerName,
    this.refNumber,
    this.totalAmount,
    this.signature,
    this.customerImage,
    List<InvoiceModel>? invoicesList,
    this.deliveryNumber,
    this.transactionDate,
    this.transactionStatusString,
    this.modeOfPaymentString,
    this.createdAt,
    this.updatedAt,
    this.isCompleted,
    this.pdf,
    this.trip,
    this.tripRef,
    this.customerModel,
    this.customer,
    this.completedCustomer,
    this.completedCustomerRef,
  }) : invoices = invoicesList ?? [];

  TransactionStatus get transactionStatus =>
      TransactionStatus.values.firstWhere(
        (status) => status.toString() == transactionStatusString,
        orElse: () => TransactionStatus.pending,
      );

  ModeOfPayment get modeOfPayment => ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

  @override
  List<Object?> get props => [
        id,
        customerModel,
        customerName,
        totalAmount,
        signature,
        customerImage,
        invoices,
        deliveryNumber,
        transactionDate,
        transactionStatusString,
        createdAt,
        updatedAt,
        modeOfPaymentString,
        refNumber,
        isCompleted,
        pdf,
        trip,
        tripRef,
        customer,
        completedCustomer,
        completedCustomerRef,
      ];
}
