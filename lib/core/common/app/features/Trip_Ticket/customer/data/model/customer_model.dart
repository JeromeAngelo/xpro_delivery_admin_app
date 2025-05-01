import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:pocketbase/pocketbase.dart';


class CustomerModel extends CustomerEntity {
  int objectBoxId = 0;
  String pocketbaseId;
  String? tripId;

  CustomerModel({
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
    super.deliveryStatusList,
    super.numberOfInvoices,
    super.invoicesList,
    super.tripModel,
    super.latitude,
    super.longitude,
    super.created,
    super.updated,
    super.returnList,
    super.transactionList,
    super.totalTime,
    ModeOfPayment? paymentSelection,
    super.confirmedTotalPayment,
    super.hasNotes,
    this.tripId,
    super.notes,
    super.remarks,
    super.totalAmount,
    this.objectBoxId = 0,
  })  : pocketbaseId = id ?? '',
        super(
          modeOfPaymentString: paymentSelection?.toString(),
        );

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
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

    // Handle trip data
    final tripData = expandedData?['trip'];
    TripModel? tripModel;

    if (tripData != null) {
      if (tripData is RecordModel) {
        tripModel = TripModel.fromJson({
          'id': tripData.id,
          'collectionId': tripData.collectionId,
          'collectionName': tripData.collectionName,
          ...tripData.data,
        });
      } else if (tripData is List && tripData.isNotEmpty) {
        final firstTrip = tripData.first as RecordModel;
        tripModel = TripModel.fromJson({
          'id': firstTrip.id,
          'collectionId': firstTrip.collectionId,
          'collectionName': firstTrip.collectionName,
          ...firstTrip.data,
        });
      } else if (tripData is Map) {
        tripModel = TripModel.fromJson(tripData as Map<String, dynamic>);
      }
    }

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

    // Enhanced invoice parsing with direct access to expanded data
    final invoicesList = (expandedData?['invoices(customer)'] as List?)
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

    final transactionList = (expandedData?['transactions'] as List?)
            ?.map((transaction) =>
                TransactionModel.fromJson(transaction as DataMap))
            .toList() ??
        [];

    final returnList = (expandedData?['returns'] as List?)
            ?.map((returnItem) => ReturnModel.fromJson(returnItem as DataMap))
            .toList() ??
        [];

    return CustomerModel(
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
      numberOfInvoices: invoicesList.length,
totalAmount: json['totalAmount']?.toString(),
      confirmedTotalPayment:
          double.tryParse(json['confirmedTotalPayment']?.toString() ?? '0.0'),
      hasNotes: json['hasNotes'] as bool? ?? false,
      tripModel: tripModel,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      returnList: returnList,
      remarks: json['remarks']?.toString(),
      notes: json['notes']?.toString(),
      totalTime: json['totalTime']?.toString(),
      transactionList: transactionList,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
      tripId: tripModel?.id,
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
      'confirmedTotalPayment': confirmedTotalPayment?.toString() ?? '',
      'hasNotes': hasNotes ?? false,
      'deliveryStatus':
          deliveryStatus.map((status) => status.toJson()).toList(),
      'invoices': invoices.map((invoice) => invoice.toJson()).toList(),
      'trip': tripId ?? '',
      'numberOfInvoices': numberOfInvoices?.toString() ?? '',
      'totalAmount': totalAmount?.toString() ?? '',
      'returnList': returnList.map((r) => r.toJson()).toList(),
      'transactionList': transactionList.map((t) => t.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'payment_selection': paymentSelection.toString().split('.').last,
      'notes': notes,
      'remarks': remarks,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
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
    List<DeliveryUpdateModel>? deliveryStatusList,
    int? numberOfInvoices,
String? totalAmount,
    List<InvoiceModel>? invoicesList,
    TripModel? tripModel,
    String? latitude,
    String? longitude,
    DateTime? created,
    DateTime? updated,
    List<ReturnModel>? returnList,
    List<TransactionModel>? transactionList,
    String? totalTime,
    ModeOfPayment? paymentSelection,
    double? confirmedTotalPayment,
    bool? hasNotes,
    String? tripId,
    String? notes,
    String? remarks,
  }) {
    return CustomerModel(
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
      deliveryStatusList: deliveryStatusList ?? deliveryStatus,
      numberOfInvoices: numberOfInvoices ?? this.numberOfInvoices,
      totalAmount: totalAmount ?? this.totalAmount,
      invoicesList: invoicesList ?? this.invoicesList,
      tripModel: tripModel ?? trip,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      returnList: returnList ?? this.returnList,
      transactionList: transactionList ?? this.transactionList,
      totalTime: totalTime ?? this.totalTime,
      paymentSelection: paymentSelection ?? this.paymentSelection,
      confirmedTotalPayment: confirmedTotalPayment ?? this.confirmedTotalPayment,
      hasNotes: hasNotes ?? this.hasNotes,
      tripId: tripId ?? this.tripId,
      notes: notes ?? this.notes,
      remarks: remarks ?? this.remarks,
      objectBoxId: objectBoxId,
    );
  }

  @override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  return other is CustomerModel && other.id == id;
}

@override
int get hashCode => id.hashCode;

}
