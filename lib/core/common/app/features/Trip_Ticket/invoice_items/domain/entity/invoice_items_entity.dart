import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';

class InvoiceItemsEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? name;
  final String? brand;
  final String? refId;
  final String? uom;
  final double? quantity;
  final double? totalBaseQuantity;
  final double? uomPrice;
  final double? totalAmount;
  final InvoiceDataEntity? invoiceData;
  final DateTime? created;
  final DateTime? updated;

  const InvoiceItemsEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.name,
    this.brand,
    this.refId,
    this.uom,
    this.quantity,
    this.totalBaseQuantity,
    this.uomPrice,
    this.totalAmount,
    this.invoiceData,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        name,
        brand,
        refId,
        uom,
        quantity,
        totalBaseQuantity,
        uomPrice,
        totalAmount,
        invoiceData,
        created,
        updated,
      ];
}
