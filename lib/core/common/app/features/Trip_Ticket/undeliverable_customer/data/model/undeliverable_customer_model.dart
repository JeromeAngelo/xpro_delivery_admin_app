import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:desktop_app/core/enums/undeliverable_reason.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:pocketbase/pocketbase.dart';


class UndeliverableCustomerModel extends UndeliverableCustomerEntity {
  int objectBoxId = 0;
  String pocketbaseId;
  String? tripId;
  String? customerId;

  UndeliverableCustomerModel({
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
    super.invoicesList,
    super.customer,
    super.reason,
    super.time,
    super.created,
    super.updated,
    super.customerImage,
    super.trip,
    this.tripId,
    this.customerId,
    this.objectBoxId = 0,
  }) : pocketbaseId = id ?? '';

  factory UndeliverableCustomerModel.fromJson(DataMap json) {
    final expandedData = json['expand'] as Map<String, dynamic>?;

    final invoicesList = (expandedData?['invoices'] as List?)?.map((invoice) {
      if (invoice is RecordModel) {
        return InvoiceModel.fromJson({
          'id': invoice.id,
          'collectionId': invoice.collectionId,
          'collectionName': invoice.collectionName,
          ...invoice.data,
        });
      }
      return InvoiceModel.fromJson(invoice as DataMap);
    }).toList() ?? [];

    final customer = expandedData?['customer'] != null
        ? CustomerModel.fromJson(expandedData!['customer'] is RecordModel
            ? {
                'id': expandedData['customer'].id,
                'collectionId': expandedData['customer'].collectionId,
                'collectionName': expandedData['customer'].collectionName,
                ...expandedData['customer'].data,
              }
            : expandedData['customer'] as DataMap)
        : null;

    final trip = expandedData?['trip'] != null
        ? TripModel.fromJson(expandedData!['trip'] is RecordModel
            ? {
                'id': expandedData['trip'].id,
                'collectionId': expandedData['trip'].collectionId,
                'collectionName': expandedData['trip'].collectionName,
                ...expandedData['trip'].data,
              }
            : expandedData['trip'] as DataMap)
        : null;

    return UndeliverableCustomerModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      deliveryNumber: json['deliveryNumber']?.toString(),
      storeName: json['storeName']?.toString(),
      ownerName: json['ownerName']?.toString(),
      contactNumber: json['contactNumber'] is String 
          ? [json['contactNumber'] as String]
          : (json['contactNumber'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      address: json['address']?.toString(),
      municipality: json['municipality']?.toString(),
      province: json['province']?.toString(),
      modeOfPayment: json['modeOfPayment']?.toString(),
      invoicesList: invoicesList,
      customer: customer,
      reason: UndeliverableReason.values.firstWhere(
        (e) => e.name == (json['reason'] ?? 'other'),
        orElse: () => UndeliverableReason.none,
      ),
      time: json['time'] != null ? DateTime.parse(json['time'].toString()) : null,
      customerImage: json['customerImage']?.toString(),
      created: json['created'] != null ? DateTime.parse(json['created'].toString()) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated'].toString()) : null,
      trip: trip,
      tripId: json['trip']?.toString(),
      customerId: json['customer']?.toString(),
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'deliveryNumber': deliveryNumber,
      'storeName': storeName,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'address': address,
      'municipality': municipality,
      'province': province,
      'modeOfPayment': modeOfPayment,
      'invoices': invoices.map((invoice) => invoice.id).toList(),
      'customer': customerId ?? customer?.id,
      'reason': reason?.toString().split('.').last,
      'time': time?.toIso8601String(),
      'customerImage': customerImage,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'trip': tripId ?? trip?.id,
    };
  }

  UndeliverableCustomerModel copyWith({
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
    List<InvoiceModel>? invoicesList,
    CustomerModel? customer,
    UndeliverableReason? reason,
    DateTime? time,
    DateTime? created,
    DateTime? updated,
    String? customerImage,
    TripModel? trip,
    String? tripId,
    String? customerId,
  }) {
    return UndeliverableCustomerModel(
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
      invoicesList: invoicesList ?? this.invoicesList,
      customer: customer ?? this.customer,
      reason: reason ?? this.reason,
      time: time ?? this.time,
      customerImage: customerImage ?? this.customerImage,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      trip: trip ?? this.trip,
      tripId: tripId ?? this.tripId,
      customerId: customerId ?? this.customerId,
      objectBoxId: this.objectBoxId,
    );
  }
}
