import 'package:equatable/equatable.dart';

import '../../domain/entity/delivery_status_choices_entity.dart';

abstract class DeliveryStatusChoicesEvent extends Equatable {
  const DeliveryStatusChoicesEvent();
}

/// 📦 Get ASSIGNED / ALLOWED status choices for a DeliveryData
class GetAllAssignedDeliveryStatusChoicesEvent
    extends DeliveryStatusChoicesEvent {
  final String deliveryDataId;

  const GetAllAssignedDeliveryStatusChoicesEvent(this.deliveryDataId);

  @override
  List<Object?> get props => [deliveryDataId];
}

/// 📝 Update delivery status (choice selected)
class UpdateCustomerStatusEvent extends DeliveryStatusChoicesEvent {
  final String deliveryDataId;
  final DeliveryStatusChoicesEntity status;

  const UpdateCustomerStatusEvent({
    required this.deliveryDataId,
    required this.status,
  });

  @override
  List<Object?> get props => [deliveryDataId, status];
}