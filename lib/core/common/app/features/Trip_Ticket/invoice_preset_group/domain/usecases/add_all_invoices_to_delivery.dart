import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/repo/invoice_preset_group_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class AddAllInvoicesToDeliveryParams extends Equatable {
  final String presetGroupId;
  final String deliveryId;

  const AddAllInvoicesToDeliveryParams({
    required this.presetGroupId,
    required this.deliveryId,
  });

  @override
  List<Object?> get props => [presetGroupId, deliveryId];
}

class AddAllInvoicesToDelivery extends UsecaseWithParams<void, AddAllInvoicesToDeliveryParams> {
  const AddAllInvoicesToDelivery(this._repo);

  final InvoicePresetGroupRepo _repo;

  @override
  ResultFuture<void> call(AddAllInvoicesToDeliveryParams params) async {
    return _repo.addAllInvoicesToDelivery(
      presetGroupId: params.presetGroupId,
      deliveryId: params.deliveryId,
    );
  }
}
