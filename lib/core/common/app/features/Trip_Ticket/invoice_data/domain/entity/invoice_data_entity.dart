import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';

class InvoiceDataEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? refId;
  final String? name;
  final DateTime? documentDate;
  final double? totalAmount;
  final double? volume;
  
  final double? weight;
  final CustomerDataEntity? customer;
  final DateTime? created;
  final DateTime? updated;

  const InvoiceDataEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.refId,
    this.name,
    this.documentDate,
    this.totalAmount,
    this.volume,
    this.weight,
    this.customer,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        refId,
        name,
        documentDate,
        totalAmount,
        volume,
        weight,
        customer,
        created,
        updated,
      ];
}
