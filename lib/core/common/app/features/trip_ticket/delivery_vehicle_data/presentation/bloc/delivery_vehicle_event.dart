import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';

abstract class DeliveryVehicleEvent extends Equatable {
  const DeliveryVehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliveryVehicleByIdEvent extends DeliveryVehicleEvent {
  final String vehicleId;

  const LoadDeliveryVehicleByIdEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class LoadDeliveryVehiclesByTripIdEvent extends DeliveryVehicleEvent {
  final String tripId;

  const LoadDeliveryVehiclesByTripIdEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class LoadAllDeliveryVehiclesEvent extends DeliveryVehicleEvent {
  const LoadAllDeliveryVehiclesEvent();
}

class CreateDeliveryVehicleEvent extends DeliveryVehicleEvent {
  final DeliveryVehicleEntity vehicle;

  const CreateDeliveryVehicleEvent(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class UpdateDeliveryVehicleEvent extends DeliveryVehicleEvent {
  final String id;
  final DeliveryVehicleEntity vehicle;

  const UpdateDeliveryVehicleEvent({required this.id, required this.vehicle});

  @override
  List<Object?> get props => [id, vehicle];
}
