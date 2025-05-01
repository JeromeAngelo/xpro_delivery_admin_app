import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/entity/delivery_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:equatable/equatable.dart';

abstract class DeliveryUpdateState extends Equatable {
  const DeliveryUpdateState();
}

// Existing states
class DeliveryUpdateInitial extends DeliveryUpdateState {
  @override
  List<Object> get props => [];
}

class DeliveryUpdateLoading extends DeliveryUpdateState {
  @override
  List<Object> get props => [];
}

class DeliveryStatusChoicesLoaded extends DeliveryUpdateState {
  final List<DeliveryUpdateEntity> statusChoices;
  const DeliveryStatusChoicesLoaded(this.statusChoices);
  @override
  List<Object> get props => [statusChoices];
}

class DeliveryStatusUpdateSuccess extends DeliveryUpdateState {
  const DeliveryStatusUpdateSuccess();
  @override
  List<Object> get props => [];
}

class DeliveryUpdateError extends DeliveryUpdateState {
  final String message;
  const DeliveryUpdateError(this.message);
  @override
  List<Object> get props => [message];
}

class DeliveryCompletionSuccess extends DeliveryUpdateState {
  final String customerId;
  
  const DeliveryCompletionSuccess(this.customerId);
  
  @override
  List<Object> get props => [customerId];
}

class EndDeliveryStatusChecked extends DeliveryUpdateState {
  final DataMap stats;
  final String tripId;
  
  const EndDeliveryStatusChecked({
    required this.stats,
    required this.tripId,
  });
  
  @override
  List<Object> get props => [stats, tripId];
}

class PendingStatusInitialized extends DeliveryUpdateState {
  @override
  List<Object> get props => [];
}

class DeliveryStatusCreated extends DeliveryUpdateState {
  final String customerId;
  
  const DeliveryStatusCreated(this.customerId);
  
  @override
  List<Object> get props => [customerId];
}

class QueueRemarksUpdated extends DeliveryUpdateState {
  final String customerId;
  final String queueCount;

  const QueueRemarksUpdated({
    required this.customerId,
    required this.queueCount,
  });

  @override
  List<Object> get props => [customerId, queueCount];
}

// New states
class AllDeliveryUpdatesLoaded extends DeliveryUpdateState {
  final List<DeliveryUpdateEntity> updates;
  
  const AllDeliveryUpdatesLoaded(this.updates);
  
  @override
  List<Object> get props => [updates];
}

class DeliveryUpdateCreated extends DeliveryUpdateState {
  final DeliveryUpdateEntity update;
  
  const DeliveryUpdateCreated(this.update);
  
  @override
  List<Object> get props => [update];
}

class DeliveryUpdateUpdated extends DeliveryUpdateState {
  final DeliveryUpdateEntity update;
  
  const DeliveryUpdateUpdated(this.update);
  
  @override
  List<Object> get props => [update];
}

class DeliveryUpdateDeleted extends DeliveryUpdateState {
  final String id;
  
  const DeliveryUpdateDeleted(this.id);
  
  @override
  List<Object> get props => [id];
}

class AllDeliveryUpdatesDeleted extends DeliveryUpdateState {
  final List<String> ids;
  
  const AllDeliveryUpdatesDeleted(this.ids);
  
  @override
  List<Object> get props => [ids];
}
