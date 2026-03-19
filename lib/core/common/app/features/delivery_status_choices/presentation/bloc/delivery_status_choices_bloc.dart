import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../services/injection_container.dart';
import '../../../trip_ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import '../../../trip_ticket/delivery_data/presentation/bloc/delivery_data_event.dart';
import '../../../trip_ticket/delivery_data/presentation/bloc/delivery_data_state.dart';
import '../../domain/usecases/get_all_assigned_status_choices.dart';
import '../../domain/usecases/update_customer_status.dart';
import 'delivery_status_choices_event.dart';
import 'delivery_status_choices_state.dart';

class DeliveryStatusChoicesBloc
    extends Bloc<DeliveryStatusChoicesEvent, DeliveryStatusChoicesState> {
  final GetAssignedDeliveryStatusChoices _getAssignedDeliveryStatusChoices;
  final UpdateCustomerStatus _updateCustomerStatus;
 DeliveryDataState? _cachedState;
  DeliveryStatusChoicesBloc({
    required GetAssignedDeliveryStatusChoices getAssignedDeliveryStatusChoices,
    required UpdateCustomerStatus updateCustomerStatus,
  }) : _getAssignedDeliveryStatusChoices = getAssignedDeliveryStatusChoices,
       _updateCustomerStatus = updateCustomerStatus,

       super(DeliveryStatusChoicesInitial()) {
    on<GetAllAssignedDeliveryStatusChoicesEvent>(
      _onGetAssignedDeliveryStatusChoices,
    );
    on<UpdateCustomerStatusEvent>(_onUpdateCustomerStatus);
  }

  /// 📦 Get assigned delivery status choices (offline-first)
  Future<void> _onGetAssignedDeliveryStatusChoices(
    GetAllAssignedDeliveryStatusChoicesEvent event,
    Emitter<DeliveryStatusChoicesState> emit,
  ) async {
    emit(DeliveryStatusChoicesLoading());
    debugPrint(
      '📦 Fetching assigned delivery status choices for ${event.deliveryDataId}',
    );

    final result = await _getAssignedDeliveryStatusChoices(
      event.deliveryDataId,
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to fetch assigned statuses: ${failure.message}');
        emit(DeliveryStatusChoicesError(failure.message));
      },
      (assignedStatuses) {
        debugPrint('✅ Loaded ${assignedStatuses.length} assigned statuses');
        emit(AssignedDeliveryStatusChoicesLoaded(assignedStatuses));
      },
    );
  }


  /// 📝 Update customer delivery status (offline-first + remote sync)
  Future<void> _onUpdateCustomerStatus(
    UpdateCustomerStatusEvent event,
    Emitter<DeliveryStatusChoicesState> emit,
  ) async {
    debugPrint('🔄 Updating delivery status for ${event.deliveryDataId}');
    emit(DeliveryStatusChoicesLoading());

    final result = await _updateCustomerStatus(
      UpdateDeliveryStatusParams(
        deliveryDataId: event.deliveryDataId,
        status: event.status,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Update failed: ${failure.message}');
        emit(DeliveryStatusChoicesError(failure.message));
      },
      (_) {
        debugPrint('✅ Status updated successfully');
        emit(const DeliveryStatusUpdated());

        // Optionally, refresh assigned choices to reflect new state
        add(GetAllAssignedDeliveryStatusChoicesEvent(event.deliveryDataId));
        // Trigger a by-id load so DeliveryDataBloc emits the freshly persisted
        // delivery object (this forces UI tiles to receive the updated item).
        try {
          final deliveryBloc = sl<DeliveryDataBloc>();
          deliveryBloc.add(GetDeliveryDataByIdEvent(event.deliveryDataId));
        } catch (e, st) {
          debugPrint('🔔 Unable to dispatch DeliveryData load by-id: $e\n$st');
        }
      },
    );
  }
 @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
  //
}
