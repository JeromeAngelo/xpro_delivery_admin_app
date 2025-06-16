import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';

class InvoicePresetGroupEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? refId;
  final String? name;
  final List<InvoiceDataEntity> invoices;
  final DateTime? created;
  final DateTime? updated;

  const InvoicePresetGroupEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.refId,
    this.name,
    this.invoices = const [],
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
        invoices,
        created,
        updated,
      ];
}
