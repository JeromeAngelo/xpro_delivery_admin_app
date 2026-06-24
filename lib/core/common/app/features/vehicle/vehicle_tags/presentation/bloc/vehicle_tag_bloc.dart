import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../enums/vehicle_tags_enums.dart';
import '../../domain/usecases/assign_tag_to_vehicle.dart';
import '../../domain/usecases/create_vehicle_tag.dart';
import '../../domain/usecases/delete_vehicle_tag.dart';
import '../../domain/usecases/get_vehicle_tags.dart';
import '../../domain/usecases/load_vehicle_tag_by_id.dart';
import '../../domain/usecases/unassign_tag_from_vehicle.dart';
import '../../domain/usecases/update_vehicle_tag.dart';
import 'vehicle_tag_event.dart';
import 'vehicle_tag_state.dart';

class VehicleTagBloc extends Bloc<VehicleTagEvent, VehicleTagState> {
  final GetVehicleTags _getVehicleTags;
  final LoadVehicleTagById _loadVehicleTagById;
  final CreateVehicleTag _createVehicleTag;
  final UpdateVehicleTag _updateVehicleTag;
  final DeleteVehicleTag _deleteVehicleTag;
  final AssignTagToVehicle _assignTagToVehicle;
  final UnassignTagFromVehicle _unassignTagFromVehicle;

  VehicleTagState? _cachedState;

  VehicleTagBloc({
    required GetVehicleTags getVehicleTags,
    required LoadVehicleTagById loadVehicleTagById,
    required CreateVehicleTag createVehicleTag,
    required UpdateVehicleTag updateVehicleTag,
    required DeleteVehicleTag deleteVehicleTag,
    required AssignTagToVehicle assignTagToVehicle,
    required UnassignTagFromVehicle unassignTagFromVehicle,
  }) : _getVehicleTags = getVehicleTags,
       _loadVehicleTagById = loadVehicleTagById,
       _createVehicleTag = createVehicleTag,
       _updateVehicleTag = updateVehicleTag,
       _deleteVehicleTag = deleteVehicleTag,
       _assignTagToVehicle = assignTagToVehicle,
       _unassignTagFromVehicle = unassignTagFromVehicle,
       super(const VehicleTagInitial()) {
    on<GetVehicleTagsEvent>(_onGetVehicleTags);
    on<LoadVehicleTagByIdEvent>(_onLoadVehicleTagById);
    on<CreateVehicleTagEvent>(_onCreateVehicleTag);
    on<UpdateVehicleTagEvent>(_onUpdateVehicleTag);
    on<DeleteVehicleTagEvent>(_onDeleteVehicleTag);
    on<AssignTagToVehicleEvent>(_onAssignTagToVehicle);
    on<UnassignTagFromVehicleEvent>(_onUnassignTagFromVehicle);
    on<RefreshVehicleTagsEvent>(_onRefreshVehicleTags);
  }

  Future<void> _onGetVehicleTags(
    GetVehicleTagsEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint('🔄 BLoC: Fetching all vehicle tags');
    emit(const VehicleTagLoading());

    final result = await _getVehicleTags();

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to fetch vehicle tags: ${failure.message}');
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (vehicleTags) {
        debugPrint(
          '✅ BLoC: Successfully loaded ${vehicleTags.length} vehicle tags',
        );
        if (vehicleTags.isEmpty) {
          emit(const VehicleTagEmpty());
        } else {
          final newState = VehicleTagsLoaded(vehicleTags: vehicleTags);
          emit(newState);
          _cachedState = newState;
        }
      },
    );
  }

  Future<void> _onLoadVehicleTagById(
    LoadVehicleTagByIdEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint('🔄 BLoC: Fetching vehicle tag by ID: ${event.tagId}');
    emit(const VehicleTagLoading());

    final result = await _loadVehicleTagById(event.tagId);

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to fetch vehicle tag: ${failure.message}');
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (vehicleTag) {
        debugPrint('✅ BLoC: Successfully loaded vehicle tag');
        final newState = VehicleTagLoaded(vehicleTag: vehicleTag);
        emit(newState);
        _cachedState = newState;
      },
    );
  }

  Future<void> _onCreateVehicleTag(
    CreateVehicleTagEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint('🔄 BLoC: Creating vehicle tag: ${event.label}');
    emit(const VehicleTagLoading());

    final result = await _createVehicleTag(
      CreateVehicleTagParams(
        label: event.label,
        tagType:
            event.tagType
                .map(
                  (type) => VehicleTagType.values.firstWhere(
                    (e) => e.name == type,
                    orElse: () => VehicleTagType.other,
                  ),
                )
                .toList(),
        description: event.description,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to create vehicle tag: ${failure.message}');
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (vehicleTag) {
        debugPrint('✅ BLoC: Successfully created vehicle tag');
        emit(VehicleTagCreated(vehicleTag));
      },
    );
  }

  Future<void> _onUpdateVehicleTag(
    UpdateVehicleTagEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint('🔄 BLoC: Updating vehicle tag: ${event.tagId}');
    emit(const VehicleTagLoading());

    final result = await _updateVehicleTag(
      UpdateVehicleTagParams(
        tagId: event.tagId,
        label: event.label,
        tagType:
            event.tagType
                ?.map(
                  (type) => VehicleTagType.values.firstWhere(
                    (e) => e.name == type,
                    orElse: () => VehicleTagType.other,
                  ),
                )
                .toList(),
        description: event.description,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to update vehicle tag: ${failure.message}');
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (vehicleTag) {
        debugPrint('✅ BLoC: Successfully updated vehicle tag');
        emit(VehicleTagUpdated(vehicleTag));
      },
    );
  }

  Future<void> _onDeleteVehicleTag(
    DeleteVehicleTagEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint('🔄 BLoC: Deleting vehicle tag: ${event.tagId}');
    emit(const VehicleTagLoading());

    final result = await _deleteVehicleTag(event.tagId);

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to delete vehicle tag: ${failure.message}');
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (_) {
        debugPrint('✅ BLoC: Successfully deleted vehicle tag');
        emit(VehicleTagDeleted(event.tagId));
      },
    );
  }

  Future<void> _onAssignTagToVehicle(
    AssignTagToVehicleEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint(
      '🔄 BLoC: Assigning tag ${event.tagId} to vehicle ${event.vehicleId}',
    );
    emit(const VehicleTagLoading());

    final result = await _assignTagToVehicle(
      AssignTagToVehicleParams(vehicleId: event.vehicleId, tagId: event.tagId),
    );

    result.fold(
      (failure) {
        debugPrint(
          '❌ BLoC: Failed to assign tag to vehicle: ${failure.message}',
        );
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (_) {
        debugPrint('✅ BLoC: Successfully assigned tag to vehicle');
        emit(
          TagAssignedToVehicle(vehicleId: event.vehicleId, tagId: event.tagId),
        );
      },
    );
  }

  Future<void> _onUnassignTagFromVehicle(
    UnassignTagFromVehicleEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint(
      '🔄 BLoC: Unassigning tag ${event.tagId} from vehicle ${event.vehicleId}',
    );
    emit(const VehicleTagLoading());

    final result = await _unassignTagFromVehicle(
      UnassignTagFromVehicleParams(
        vehicleId: event.vehicleId,
        tagId: event.tagId,
      ),
    );

    result.fold(
      (failure) {
        debugPrint(
          '❌ BLoC: Failed to unassign tag from vehicle: ${failure.message}',
        );
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (_) {
        debugPrint('✅ BLoC: Successfully unassigned tag from vehicle');
        emit(
          TagUnassignedFromVehicle(
            vehicleId: event.vehicleId,
            tagId: event.tagId,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshVehicleTags(
    RefreshVehicleTagsEvent event,
    Emitter<VehicleTagState> emit,
  ) async {
    debugPrint('🔄 BLoC: Refreshing vehicle tags');
    final result = await _getVehicleTags();

    result.fold(
      (failure) {
        debugPrint(
          '❌ BLoC: Failed to refresh vehicle tags: ${failure.message}',
        );
        emit(
          VehicleTagError(
            message: failure.message,
            errorCode: failure.statusCode.toString(),
          ),
        );
      },
      (vehicleTags) {
        debugPrint(
          '✅ BLoC: Successfully refreshed ${vehicleTags.length} vehicle tags',
        );
        final newState = VehicleTagsLoaded(vehicleTags: vehicleTags);
        emit(newState);
        _cachedState = newState;
      },
    );
  }
}
