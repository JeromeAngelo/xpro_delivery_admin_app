import 'package:equatable/equatable.dart';

import '../../domain/entity/delivery_status_choices_entity.dart';

abstract class DeliveryStatusChoicesState extends Equatable{
  const DeliveryStatusChoicesState();
}

class DeliveryStatusChoicesInitial extends DeliveryStatusChoicesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
  
}

class DeliveryStatusChoicesLoading extends DeliveryStatusChoicesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
  
}

class DeliveryStatusChoicesError extends DeliveryStatusChoicesState {
  final String message;
  const DeliveryStatusChoicesError(this.message);
  @override
  // TODO: implement props
  List<Object?> get props => [message];
  
}
/// 📦 Assigned / allowed choices (offline-first)
class AssignedDeliveryStatusChoicesLoaded
    extends DeliveryStatusChoicesState {
  final List<DeliveryStatusChoicesEntity> updates;

  const AssignedDeliveryStatusChoicesLoaded(this.updates);

  @override
  List<Object?> get props => [updates];
}
/// ✅ Status updated successfully
class DeliveryStatusUpdated extends DeliveryStatusChoicesState {
  const DeliveryStatusUpdated();
  
  @override
  // TODO: implement props
  List<Object?> get props => [];
}