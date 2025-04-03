import 'package:desktop_app/core/common/app/features/Delivery_Team/delivery_team/domain/entity/delivery_team_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_state.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:desktop_app/core/common/app/features/checklist/presentation/bloc/checklist_state.dart';
import 'package:equatable/equatable.dart';

abstract class DeliveryTeamState extends Equatable {
  const DeliveryTeamState();

  @override
  List<Object> get props => [];
}

class DeliveryTeamInitial extends DeliveryTeamState {
  const DeliveryTeamInitial();
}

class DeliveryTeamLoading extends DeliveryTeamState {
  const DeliveryTeamLoading();
}

class DeliveryTeamLoaded extends DeliveryTeamState {
  final DeliveryTeamEntity deliveryTeam;
  final TripState tripState;
  final PersonelState personelState;
  final VehicleState vehicleState;
  final ChecklistState checklistState;

  const DeliveryTeamLoaded({
    required this.deliveryTeam,
    required this.tripState,
    required this.personelState,
    required this.vehicleState,
    required this.checklistState,
  });

  @override
  List<Object> get props => [
    deliveryTeam, 
    tripState, 
    personelState, 
    vehicleState, 
    checklistState
  ];
}

class AllDeliveryTeamsLoaded extends DeliveryTeamState {
  final List<DeliveryTeamEntity> deliveryTeams;
  
  const AllDeliveryTeamsLoaded(this.deliveryTeams);
  
  @override
  List<Object> get props => [deliveryTeams];
}

class DeliveryTeamError extends DeliveryTeamState {
  final String message;
  const DeliveryTeamError(this.message);

  @override
  List<Object> get props => [message];
}

class DeliveryTeamAssigned extends DeliveryTeamState {
  final String deliveryTeamId;
  final String tripId;

  const DeliveryTeamAssigned({
    required this.deliveryTeamId,
    required this.tripId,
  });

  @override
  List<Object> get props => [deliveryTeamId, tripId];
}

class DeliveryTeamCreated extends DeliveryTeamState {
  final DeliveryTeamEntity deliveryTeam;
  
  const DeliveryTeamCreated(this.deliveryTeam);
  
  @override
  List<Object> get props => [deliveryTeam];
}

class DeliveryTeamUpdated extends DeliveryTeamState {
  final DeliveryTeamEntity deliveryTeam;
  
  const DeliveryTeamUpdated(this.deliveryTeam);
  
  @override
  List<Object> get props => [deliveryTeam];
}

class DeliveryTeamDeleted extends DeliveryTeamState {
  final String deliveryTeamId;
  
  const DeliveryTeamDeleted(this.deliveryTeamId);
  
  @override
  List<Object> get props => [deliveryTeamId];
}
