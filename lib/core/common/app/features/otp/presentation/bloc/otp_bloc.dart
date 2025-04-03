import 'package:desktop_app/core/common/app/features/otp/domain/usecases/create_otp.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/delete_all_otp.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/delete_otp.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/get_all_otp.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/get_generated_otp.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/load_otp_by_id.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/load_otp_by_trip_id.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/update_otp.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/verify_in_transit.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/usecases/veryfy_in_end_delivery.dart';
import 'package:desktop_app/core/common/app/features/otp/presentation/bloc/otp_event.dart';
import 'package:desktop_app/core/common/app/features/otp/presentation/bloc/otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final LoadOtpByTripId _loadOtpByTripId;
  final VerifyInTransit _verifyInTransit;
  final VerifyInEndDelivery _verifyEndDelivery;
  final GetGeneratedOtp _getGeneratedOtp;
  final LoadOtpById _loadOtpById;
  // New use cases
  final GetAllOtps _getAllOtps;
  final CreateOtp _createOtp;
  final UpdateOtp _updateOtp;
  final DeleteOtp _deleteOtp;
  final DeleteAllOtps _deleteAllOtps;

  OtpBloc({
    required LoadOtpByTripId loadOtpByTripId,
    required VerifyInTransit verifyInTransit,
    required VerifyInEndDelivery verifyEndDelivery,
    required GetGeneratedOtp getGeneratedOtp,
    required LoadOtpById loadOtpById,
    required GetAllOtps getAllOtps,
    required CreateOtp createOtp,
    required UpdateOtp updateOtp,
    required DeleteOtp deleteOtp,
    required DeleteAllOtps deleteAllOtps,
  })  : _loadOtpByTripId = loadOtpByTripId,
        _verifyInTransit = verifyInTransit,
        _verifyEndDelivery = verifyEndDelivery,
        _getGeneratedOtp = getGeneratedOtp,
        _loadOtpById = loadOtpById,
        _getAllOtps = getAllOtps,
        _createOtp = createOtp,
        _updateOtp = updateOtp,
        _deleteOtp = deleteOtp,
        _deleteAllOtps = deleteAllOtps,
        super(const OtpInitial()) {
          on<LoadOtpByIdEvent>(_onLoadOtpById);
          on<LoadOtpByTripIdEvent>(_onLoadOtpByTripId);
          on<VerifyInTransitOtpEvent>(_onVerifyInTransitOtp);
          on<VerifyEndDeliveryOtpEvent>(_onVerifyEndDeliveryOtp);
          on<GetGeneratedOtpEvent>(_onGetGeneratedOtp);
          // Register new event handlers
          on<GetAllOtpsEvent>(_onGetAllOtps);
          on<CreateOtpEvent>(_onCreateOtp);
          on<UpdateOtpEvent>(_onUpdateOtp);
          on<DeleteOtpEvent>(_onDeleteOtp);
          on<DeleteAllOtpsEvent>(_onDeleteAllOtps);
  }

  Future<void> _onLoadOtpById(
    LoadOtpByIdEvent event,
    Emitter<OtpState> emit,
  ) async {
    debugPrint('🔄 Loading OTP by ID: ${event.otpId}');
    emit(const OtpLoading());

    final result = await _loadOtpById(event.otpId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load OTP: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ OTP loaded successfully');
        emit(OtpByIdLoaded(otp));
      },
    );
  }

  Future<void> _onLoadOtpByTripId(
    LoadOtpByTripIdEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Loading OTP for trip: ${event.tripId}');

    final result = await _loadOtpByTripId(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load OTP: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ OTP loaded successfully');
        emit(OtpDataLoaded(otp));
      },
    );
  }

  Future<void> _onGetGeneratedOtp(
    GetGeneratedOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Getting generated OTP...');

    final result = await _getGeneratedOtp();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get OTP: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (generatedOtp) {
        debugPrint('✅ Generated OTP received');
        emit(OtpLoaded(generatedOtp: generatedOtp));
      },
    );
  }

  Future<void> _onVerifyInTransitOtp(
    VerifyInTransitOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    debugPrint('🔄 Verifying In-Transit OTP...');
    emit(const OtpLoading());

    final result = await _verifyInTransit(
      VerifyInTransitParams(
        enteredOtp: event.enteredOtp,
        generatedOtp: event.generatedOtp,
        tripId: event.tripId,
        otpId: event.otpId,
        odometerReading: event.odometerReading,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ OTP verification failed: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (isVerified) {
        debugPrint('✅ OTP verification complete: $isVerified');
        emit(OtpVerified(
          isVerified: isVerified,
          otpType: 'inTransit',
          odometerReading: event.odometerReading,
        ));
      },
    );
  }

  Future<void> _onVerifyEndDeliveryOtp(
    VerifyEndDeliveryOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    debugPrint('🔄 Verifying End-Delivery OTP...');
    emit(const OtpLoading());

    final result = await _verifyEndDelivery(
      VerifyInEndDeliveryParams(
        enteredOtp: event.enteredOtp,
        generatedOtp: event.generatedOtp,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ End-Delivery OTP verification failed: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (isVerified) {
        debugPrint('✅ End-Delivery OTP verification complete: $isVerified');
        emit(OtpVerified(
          isVerified: isVerified,
          otpType: 'endDelivery',
        ));
      },
    );
  }

  // New event handlers
  Future<void> _onGetAllOtps(
    GetAllOtpsEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Getting all OTPs...');

    final result = await _getAllOtps();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all OTPs: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (otps) {
        debugPrint('✅ Retrieved ${otps.length} OTPs successfully');
        emit(AllOtpsLoaded(otps));
      },
    );
  }

  Future<void> _onCreateOtp(
    CreateOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Creating new OTP...');

    final result = await _createOtp(
      CreateOtpParams(
        otpCode: event.otpCode,
        tripId: event.tripId,
        generatedCode: event.generatedCode,
        intransitOdometer: event.intransitOdometer,
        isVerified: event.isVerified,
        verifiedAt: event.verifiedAt,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create OTP: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ OTP created successfully with ID: ${otp.id}');
        emit(OtpCreated(otp));
      },
    );
  }

  Future<void> _onUpdateOtp(
    UpdateOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Updating OTP: ${event.id}');

    final result = await _updateOtp(
      UpdateOtpParams(
        id: event.id,
        otpCode: event.otpCode,
        tripId: event.tripId,
        generatedCode: event.generatedCode,
        intransitOdometer: event.intransitOdometer,
        isVerified: event.isVerified,
        verifiedAt: event.verifiedAt,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to update OTP: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ OTP updated successfully');
        emit(OtpUpdated(otp));
      },
    );
  }

  Future<void> _onDeleteOtp(
    DeleteOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Deleting OTP: ${event.id}');

    final result = await _deleteOtp(event.id);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete OTP: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (_) {
        debugPrint('✅ OTP deleted successfully');
        emit(OtpDeleted(event.id));
      },
    );
  }

  Future<void> _onDeleteAllOtps(
    DeleteAllOtpsEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    debugPrint('🔄 Deleting multiple OTPs: ${event.ids.length} items');

    final result = await _deleteAllOtps(event.ids as DeleteAllOtpsParams);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete OTPs: ${failure.message}');
        emit(OtpError(message: failure.message));
      },
      (_) {
        debugPrint('✅ All OTPs deleted successfully');
        emit(AllOtpsDeleted(event.ids));
      },
    );
  }
}
