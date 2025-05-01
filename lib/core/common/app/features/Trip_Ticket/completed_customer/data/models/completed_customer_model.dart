import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:pocketbase/pocketbase.dart';


class CompletedCustomerModel extends CompletedCustomerEntity {
  int objectBoxId = 0;
  String pocketbaseId;
  String? tripId;

  CompletedCustomerModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.deliveryNumber,
    super.storeName,
    super.ownerName,
    super.contactNumber,
    super.address,
    super.municipality,
    super.province,
    super.modeOfPayment,
    super.timeCompleted,
    super.totalAmount,
    super.invoicesList,
    super.transaction,
    super.returnList,
    super.customer,
    ModeOfPayment? paymentSelection,
    super.totalTime,
    super.deliveryStatusList,
    super.tripModel,
    this.tripId,
    this.objectBoxId = 0,
  }) : pocketbaseId = id ?? '',
       super(
         modeOfPaymentString: paymentSelection?.toString(),
       );

  factory CompletedCustomerModel.fromJson(DataMap json) {
    final expandedData = json['expand'] as Map<String, dynamic>?;

    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Enhanced delivery status parsing
    final deliveryStatusList = (expandedData?['deliveryStatus'] as List?)
            ?.map((status) {
              if (status == null) return null;
              return DeliveryUpdateModel.fromJson(status is RecordModel
                  ? {
                      'id': status.id,
                      'collectionId': status.collectionId,
                      'collectionName': status.collectionName,
                      ...status.data,
                    }
                  : status as DataMap);
            })
            .whereType<DeliveryUpdateModel>()
            .toList() ??
        [];

    // Enhanced invoice parsing
    final invoicesList = (expandedData?['invoices'] as List?)
            ?.map((invoice) => InvoiceModel.fromJson({
                  'id': invoice['id'],
                  'collectionId': invoice['collectionId'],
                  'collectionName': invoice['collectionName'],
                  'invoiceNumber': invoice['invoiceNumber'],
                  'status': invoice['status'],
                  'productList': invoice['productsList'] ?? [],
                  'customer': invoice['customer'],
                  'created': invoice['created'],
                  'updated': invoice['updated'],
                }))
            .toList() ??
        [];

    // Map transaction
    final transactionData = expandedData?['transaction'];
    TransactionModel? transaction;
    if (transactionData != null) {
      if (transactionData is RecordModel) {
        transaction = TransactionModel.fromJson({
          'id': transactionData.id,
          'collectionId': transactionData.collectionId,
          'collectionName': transactionData.collectionName,
          ...transactionData.data,
        });
      } else if (transactionData is Map) {
        transaction = TransactionModel.fromJson(
            transactionData as Map<String, dynamic>);
      }
    }

    // Map customer
    final customerData = expandedData?['customer'];
    CustomerModel? customer;
    if (customerData != null) {
      if (customerData is RecordModel) {
        customer = CustomerModel.fromJson({
          'id': customerData.id,
          'collectionId': customerData.collectionId,
          'collectionName': customerData.collectionName,
          ...customerData.data,
        });
      } else if (customerData is Map) {
        customer = CustomerModel.fromJson(
            customerData as Map<String, dynamic>);
      }
    }

    // Map returns
    final returnList = (expandedData?['returns'] as List?)
            ?.map((returnItem) => ReturnModel.fromJson(returnItem as DataMap))
            .toList() ??
        [];

    // Map trip
    final tripData = expandedData?['trip'];
    TripModel? trip;
    if (tripData != null) {
      if (tripData is RecordModel) {
        trip = TripModel.fromJson({
          'id': tripData.id,
          'collectionId': tripData.collectionId,
          'collectionName': tripData.collectionName,
          ...tripData.data,
        });
      } else if (tripData is Map) {
        trip = TripModel.fromJson(tripData as Map<String, dynamic>);
      }
    }

    return CompletedCustomerModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      deliveryNumber: json['deliveryNumber']?.toString(),
      ownerName: json['ownerName']?.toString(),
      storeName: json['storeName']?.toString(),
      contactNumber: json['contactNumber'] is String
          ? [json['contactNumber'] as String]
          : (json['contactNumber'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      address: json['address']?.toString(),
      municipality: json['municipality']?.toString(),
      province: json['province']?.toString(),
      modeOfPayment: json['modeOfPayment']?.toString(),
      paymentSelection: ModeOfPayment.values.firstWhere(
          (mode) => mode.toString() == 'ModeOfPayment.${json['modeOfPayment']}',
          orElse: () => ModeOfPayment.cashOnDelivery),
      deliveryStatusList: deliveryStatusList,
      invoicesList: invoicesList,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0.0'),
      timeCompleted: parseDate(json['timeCompleted']),
      transaction: transaction,
      returnList: returnList,
      customer: customer,
      totalTime: json['totalTime']?.toString(),
      tripModel: trip,
      tripId: trip?.id,
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'deliveryNumber': deliveryNumber ?? '',
      'storeName': storeName ?? '',
      'ownerName': ownerName ?? '',
      'contactNumber': contactNumber ?? '',
      'address': address ?? '',
      'municipality': municipality ?? '',
      'province': province ?? '',
      'modeOfPayment': modeOfPayment ?? '',
      'totalTime': totalTime ?? '',
      'timeCompleted': timeCompleted?.toIso8601String(),
      'deliveryStatus': deliveryStatus.map((status) => status.toJson()).toList(),
      'invoices': invoices.map((invoice) => invoice.toJson()).toList(),
      'transaction': transaction?.toJson(),
      'returns': returnList.map((r) => r.toJson()).toList(),
      'customer': customer?.toJson(),
      'trip': tripId ?? '',
      'totalAmount': totalAmount?.toString() ?? '',
      'payment_selection': paymentSelection.toString().split('.').last,
      'created': null,
      'updated': null,
    };
  }

  CompletedCustomerModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? deliveryNumber,
    String? storeName,
    String? ownerName,
    List<String>? contactNumber,
    String? address,
    String? municipality,
    String? province,
    String? modeOfPayment,
    DateTime? timeCompleted,
    double? totalAmount,
    List<InvoiceModel>? invoicesList,
    TransactionModel? transaction,
    List<ReturnModel>? returnList,
    CustomerModel? customer,
    ModeOfPayment? paymentSelection,
    String? totalTime,
    List<DeliveryUpdateModel>? deliveryStatusList,
    TripModel? tripModel,
    String? tripId,
  }) {
    return CompletedCustomerModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      deliveryNumber: deliveryNumber ?? this.deliveryNumber,
      storeName: storeName ?? this.storeName,
      ownerName: ownerName ?? this.ownerName,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      municipality: municipality ?? this.municipality,
      province: province ?? this.province,
      modeOfPayment: modeOfPayment ?? this.modeOfPayment,
      timeCompleted: timeCompleted ?? this.timeCompleted,
      totalAmount: totalAmount ?? this.totalAmount,
      invoicesList: invoicesList ?? this.invoicesList,
      transaction: transaction ?? this.transaction,
      returnList: returnList ?? this.returnList,
      customer: customer ?? this.customer,
      paymentSelection: paymentSelection ?? this.paymentSelection,
      totalTime: totalTime ?? this.totalTime,
      deliveryStatusList: deliveryStatusList ?? this.deliveryStatus,
      tripModel: tripModel ?? this.trip,
      tripId: tripId ?? this.tripId,
      objectBoxId: this.objectBoxId,
    );
  }
}
