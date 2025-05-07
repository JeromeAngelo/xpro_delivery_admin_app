import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/usecases/get_user_trip_collection_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/presentation/bloc/users_trip_collection_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/presentation/bloc/users_trip_collection_state.dart';

class UsersTripCollectionBloc
    extends Bloc<UsersTripCollectionEvent, UsersTripCollectionState> {
  final GetUserTripCollectionUsecase _getUserTripCollectionUsecase;

  // Stream subscriptions for real-time updates
  StreamSubscription? _tripCollectionsSubscription;

  UsersTripCollectionState? _cachedState;

  UsersTripCollectionBloc({
    required GetUserTripCollectionUsecase getUserTripCollectionUsecase,
  }) : _getUserTripCollectionUsecase = getUserTripCollectionUsecase,
       super(const UsersTripCollectionInitial()) {
    on<GetUserTripCollectionsEvent>(_onGetUserTripCollections);
  }

  Future<void> _onGetUserTripCollections(
    GetUserTripCollectionsEvent event,
    Emitter<UsersTripCollectionState> emit,
  ) async {
    emit(const UsersTripCollectionLoading());
    debugPrint('🌐 Fetching trip collections for user: ${event.userId}');

    final result = await _getUserTripCollectionUsecase(
      GetUserTripCollectionParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to get trip collections: ${failure.message}');
        emit(UsersTripCollectionError(failure.message));
      },
      (tripCollections) {
        debugPrint(
          '✅ Successfully loaded ${tripCollections.length} trip collections',
        );
        final newState = UsersTripCollectionsLoaded(tripCollections);
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;

    // Clean up all subscriptions
    _tripCollectionsSubscription?.cancel();

    return super.close();
  }
}
