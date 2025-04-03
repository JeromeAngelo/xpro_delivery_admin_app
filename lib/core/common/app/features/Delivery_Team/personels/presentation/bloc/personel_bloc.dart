import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/create_personels.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/delete_all_personels.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/delete_personels.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/get_personels.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/load_personels_by_delivery_team.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/load_personels_by_trip_Id.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/set_role.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/usecase/update_personels.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_event.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonelBloc extends Bloc<PersonelEvent, PersonelState> {
  final GetPersonels _getPersonels;
  final SetRole _setRole;
  final LoadPersonelsByTripId _loadPersonelsByTripId;
  final LoadPersonelsByDeliveryTeam _loadPersonelsByDeliveryTeam;
  final CreatePersonel _createPersonel;
  final UpdatePersonel _updatePersonel;
  final DeletePersonel _deletePersonel;
  final DeleteAllPersonels _deleteAllPersonels;

  PersonelBloc({
    required GetPersonels getPersonels,
    required SetRole setRole,
    required LoadPersonelsByTripId loadPersonelsByTripId,
    required LoadPersonelsByDeliveryTeam loadPersonelsByDeliveryTeam,
    required CreatePersonel createPersonel,
    required UpdatePersonel updatePersonel,
    required DeletePersonel deletePersonel,
    required DeleteAllPersonels deleteAllPersonels,
  })  : _getPersonels = getPersonels,
        _setRole = setRole,
        _loadPersonelsByTripId = loadPersonelsByTripId,
        _loadPersonelsByDeliveryTeam = loadPersonelsByDeliveryTeam,
        _createPersonel = createPersonel,
        _updatePersonel = updatePersonel,
        _deletePersonel = deletePersonel,
        _deleteAllPersonels = deleteAllPersonels,
        super(const PersonelInitial()) {
    on<GetPersonelEvent>(_onGetPersonelsHandler);
    on<SetRoleEvent>(_onSetRoleHandler);
    on<LoadPersonelsByTripIdEvent>(_onLoadPersonelsByTripId);
    on<LoadPersonelsByDeliveryTeamEvent>(_onLoadPersonelsByDeliveryTeam);
    on<CreatePersonelEvent>(_onCreatePersonel);
    on<UpdatePersonelEvent>(_onUpdatePersonel);
    on<DeletePersonelEvent>(_onDeletePersonel);
    on<DeleteAllPersonelsEvent>(_onDeleteAllPersonels);
  }

  Future<void> _onGetPersonelsHandler(
    GetPersonelEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Getting all personnel');
    
    final result = await _getPersonels();
    result.fold(
      (failure) {
        debugPrint('❌ Error getting personnel: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (personels) {
        debugPrint('✅ Successfully retrieved ${personels.length} personnel');
        emit(PersonelLoaded(personels));
      },
    );
  }

  Future<void> _onSetRoleHandler(
    SetRoleEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Setting role for personnel ${event.id} to ${event.newRole}');
    
    final result = await _setRole(
      SetRoleParams(id: event.id, newRole: event.newRole),
    );
    result.fold(
      (failure) {
        debugPrint('❌ Error setting role: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully set role to ${event.newRole}');
        emit(SetRoleState(event.newRole));
      },
    );
  }

  Future<void> _onLoadPersonelsByTripId(
    LoadPersonelsByTripIdEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Loading personnel for trip: ${event.tripId}');
    
    final result = await _loadPersonelsByTripId(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Error loading personnel by trip: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (personels) {
        debugPrint('✅ Successfully loaded ${personels.length} personnel for trip');
        emit(PersonelsByTripLoaded(personels));
      },
    );
  }

  Future<void> _onLoadPersonelsByDeliveryTeam(
    LoadPersonelsByDeliveryTeamEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Loading personnel for delivery team: ${event.deliveryTeamId}');
    
    final result = await _loadPersonelsByDeliveryTeam(event.deliveryTeamId);
    result.fold(
      (failure) {
        debugPrint('❌ Error loading personnel by delivery team: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (personels) {
        debugPrint('✅ Successfully loaded ${personels.length} personnel for delivery team');
        emit(PersonelsByDeliveryTeamLoaded(personels));
      },
    );
  }

  Future<void> _onCreatePersonel(
    CreatePersonelEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Creating new personnel: ${event.name}');
    
    final result = await _createPersonel(
      CreatePersonelParams(
        name: event.name,
        role: event.role,
        deliveryTeamId: event.deliveryTeamId,
        tripId: event.tripId,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Error creating personnel: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (personel) {
        debugPrint('✅ Successfully created personnel with ID: ${personel.id}');
        emit(PersonelCreated(personel));
      },
    );
  }

  Future<void> _onUpdatePersonel(
    UpdatePersonelEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Updating personnel: ${event.personelId}');
    
    final result = await _updatePersonel(
      UpdatePersonelParams(
        personelId: event.personelId,
        name: event.name,
        role: event.role,
        deliveryTeamId: event.deliveryTeamId,
        tripId: event.tripId,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Error updating personnel: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (personel) {
        debugPrint('✅ Successfully updated personnel: ${personel.id}');
        emit(PersonelUpdated(personel));
      },
    );
  }

  Future<void> _onDeletePersonel(
    DeletePersonelEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Deleting personnel: ${event.personelId}');
    
    final result = await _deletePersonel(event.personelId);
    
    result.fold(
      (failure) {
        debugPrint('❌ Error deleting personnel: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted personnel');
        emit(PersonelDeleted(event.personelId));
      },
    );
  }

  Future<void> _onDeleteAllPersonels(
    DeleteAllPersonelsEvent event,
    Emitter<PersonelState> emit,
  ) async {
    emit(const PersonelLoading());
    debugPrint('🔄 Deleting multiple personnel: ${event.personelIds.length} items');
    
    final result = await _deleteAllPersonels(
      DeleteAllPersonelsParams(personelIds: event.personelIds),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Error deleting multiple personnel: ${failure.message}');
        emit(PersonelError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all personnel');
        emit(AllPersonelsDeleted(event.personelIds));
      },
    );
  }
}
