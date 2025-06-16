import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/data/model/invoice_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/entity/invoice_preset_group_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:pocketbase/pocketbase.dart';

class InvoicePresetGroupModel extends InvoicePresetGroupEntity {
  int objectBoxId = 0;
  String pocketbaseId;

  InvoicePresetGroupModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.refId,
    super.name,
    List<InvoiceDataModel>? invoices,
    super.created,
    super.updated,
    this.objectBoxId = 0,
  }) : 
    pocketbaseId = id ?? '',
    super(invoices: invoices ?? []);

  factory InvoicePresetGroupModel.fromJson(DataMap json) {
    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Handle expanded data for invoices relation
    final expandedData = json['expand'] as Map<String, dynamic>?;
    List<InvoiceDataModel> invoicesList = [];

    if (expandedData != null && expandedData.containsKey('invoices')) {
      final invoicesData = expandedData['invoices'];
      if (invoicesData != null) {
        if (invoicesData is List) {
          invoicesList = invoicesData.map((invoice) {
            if (invoice is RecordModel) {
              return InvoiceDataModel.fromJson({
                'id': invoice.id,
                'collectionId': invoice.collectionId,
                'collectionName': invoice.collectionName,
                ...invoice.data,
                'expand': invoice.expand,
              });
            } else if (invoice is Map) {
              return InvoiceDataModel.fromJson(invoice as DataMap);
            }
            // If it's just an ID string, create a minimal model
            return InvoiceDataModel(id: invoice.toString());
          }).toList();
        }
      }
    }

    return InvoicePresetGroupModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      refId: json['refId']?.toString(),
      name: json['name']?.toString(),
      invoices: invoicesList,
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
      'invoices': invoices.map((invoice) => invoice.id).toList(),
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  InvoicePresetGroupModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? refId,
    String? name,
    List<InvoiceDataModel>? invoices,
    DateTime? created,
    DateTime? updated,
  }) {
    return InvoicePresetGroupModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      refId: refId ?? this.refId,
      name: name ?? this.name,
      invoices: invoices ?? (this.invoices.map((invoice) => 
        invoice is InvoiceDataModel ? invoice : InvoiceDataModel(
          id: invoice.id,
          collectionId: invoice.collectionId,
          collectionName: invoice.collectionName,
          refId: invoice.refId,
          name: invoice.name,
          documentDate: invoice.documentDate,
          totalAmount: invoice.totalAmount,
          volume: invoice.volume,
          weight: invoice.weight,
          created: invoice.created,
          updated: invoice.updated,
          customer: invoice.customer,
        )
      ).toList()),
      created: created ?? this.created,
      updated: updated ?? this.updated,
      objectBoxId: objectBoxId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoicePresetGroupModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InvoicePresetGroupModel(id: $id, name: $name, invoices: ${invoices.length})';
  }
}
