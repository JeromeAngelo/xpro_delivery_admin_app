import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/data/model/customer_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:pocketbase/pocketbase.dart';

class InvoiceDataModel extends InvoiceDataEntity {
  int objectBoxId = 0;
  String pocketbaseId;

  InvoiceDataModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.refId,
    super.name,
    super.documentDate,
    super.totalAmount,
    super.volume,
    super.weight,
    super.customer,
    super.created,
    super.updated,
    this.objectBoxId = 0,
  }) : pocketbaseId = id ?? '';

  factory InvoiceDataModel.fromJson(DataMap json) {
    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Handle expanded data for customer relation
    final expandedData = json['expand'] as Map<String, dynamic>?;
    CustomerDataModel? customerModel;

    if (expandedData != null && expandedData.containsKey('customer')) {
      final customerData = expandedData['customer'];
      if (customerData != null) {
        if (customerData is RecordModel) {
          customerModel = CustomerDataModel.fromJson({
            'id': customerData.id,
            'collectionId': customerData.collectionId,
            'collectionName': customerData.collectionName,
            ...customerData.data,
          });
        } else if (customerData is Map) {
          customerModel = CustomerDataModel.fromJson(customerData as DataMap);
        }
      }
    }

    return InvoiceDataModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      refId: json['refId']?.toString(),
      name: json['name']?.toString(),
      documentDate: parseDate(json['documentDate']),
      totalAmount: json['totalAmount'] != null ? double.tryParse(json['totalAmount'].toString()) : null,
      volume: json['volume'] != null ? double.tryParse(json['volume'].toString()) : null,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      customer: customerModel,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'refId': refId ?? '',
      'name': name ?? '',
      'documentDate': documentDate?.toIso8601String() ?? '',
      'totalAmount': totalAmount?.toString() ?? '',
      'volume': volume?.toString() ?? '',
      'weight': weight?.toString() ?? '',
      'customer': customer?.id ?? '',
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  InvoiceDataModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? refId,
    String? name,
    DateTime? documentDate,
    double? totalAmount,
    double? volume,
    double? weight,
    CustomerDataModel? customer,
    DateTime? created,
    DateTime? updated,
  }) {
    return InvoiceDataModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      refId: refId ?? this.refId,
      name: name ?? this.name,
      documentDate: documentDate ?? this.documentDate,
      totalAmount: totalAmount ?? this.totalAmount,
      volume: volume ?? this.volume,
      weight: weight ?? this.weight,
      customer: customer ?? this.customer,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      objectBoxId: objectBoxId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceDataModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
