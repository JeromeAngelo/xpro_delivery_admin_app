import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/create_end_trip_otp.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/delete_all_end_trip_otp.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/delete_end_trip_otp.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/end_otp_verify.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/get_all_end_trip_otp.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/get_end_trip_generated.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/load_end_trip_otp_by_id.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/load_end_trip_otp_by_trip_id.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/usecases/update_end_trip_otp.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_event.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EndTripOtpBloc extends Bloc<EndTripOtpEvent, EndTripOtpState> {
  final EndOTPVerify _verifyEndTripOtp;
  final GetEndTripGeneratedOtp _getGeneratedEndTripOtp;
  final LoadEndTripOtpById _loadEndTripOtpById;
  final LoadEndTripOtpByTripId _loadEndTripOtpByTripId;
  final GetAllEndTripOtps _getAllEndTripOtps;
  final CreateEndTripOtp _createEndTripOtp;
  final UpdateEndTripOtp _updateEndTripOtp;
  final DeleteEndTripOtp _deleteEndTripOtp;
  final DeleteAllEndTripOtps _deleteAllEndTripOtps;

  EndTripOtpBloc({
    required EndOTPVerify verifyEndTripOtp,
    required GetEndTripGeneratedOtp getGeneratedEndTripOtp,
    required LoadEndTripOtpById loadEndTripOtpById,
    required LoadEndTripOtpByTripId loadEndTripOtpByTripId,
    required GetAllEndTripOtps getAllEndTripOtps,
    required CreateEndTripOtp createEndTripOtp,
    required UpdateEndTripOtp updateEndTripOtp,
    required DeleteEndTripOtp deleteEndTripOtp,
    required DeleteAllEndTripOtps deleteAllEndTripOtps,
  })  : _verifyEndTripOtp = verifyEndTripOtp,
        _getGeneratedEndTripOtp = getGeneratedEndTripOtp,
        _loadEndTripOtpById = loadEndTripOtpById,
        _loadEndTripOtpByTripId = loadEndTripOtpByTripId,
        _getAllEndTripOtps = getAllEndTripOtps,
        _createEndTripOtp = createEndTripOtp,
        _updateEndTripOtp = updateEndTripOtp,
        _deleteEndTripOtp = deleteEndTripOtp,
        _deleteAllEndTripOtps = deleteAllEndTripOtps,
        super(const EndTripOtpInitial()) {
    on<LoadEndTripOtpByIdEvent>(_onLoadEndTripOtpById);
    on<LoadEndTripOtpByTripIdEvent>(_onLoadEndTripOtpByTripId);
    on<VerifyEndTripOtpEvent>(_onVerifyEndTripOtp);
    on<GetEndGeneratedOtpEvent>(_onGetEndGeneratedOtp);
    on<GetAllEndTripOtpsEvent>(_onGetAllEndTripOtps);
    on<CreateEndTripOtpEvent>(_onCreateEndTripOtp);
    on<UpdateEndTripOtpEvent>(_onUpdateEndTripOtp);
    on<DeleteEndTripOtpEvent>(_onDeleteEndTripOtp);
    on<DeleteAllEndTripOtpsEvent>(_onDeleteAllEndTripOtps);
  }

  Future<void> _onLoadEndTripOtpById(
    LoadEndTripOtpByIdEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Loading End Trip OTP by ID: ${event.otpId}');
    emit(const EndTripOtpLoading());

    final result = await _loadEndTripOtpById(event.otpId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load End Trip OTP: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ End Trip OTP loaded successfully');
        emit(EndTripOtpByIdLoaded(otp));
      },
    );
  }

  Future<void> _onLoadEndTripOtpByTripId(
    LoadEndTripOtpByTripIdEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Loading End Trip OTP for trip: ${event.tripId}');
    emit(const EndTripOtpLoading());

    final result = await _loadEndTripOtpByTripId(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load End Trip OTP: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ End Trip OTP loaded successfully');
        emit(EndTripOtpDataLoaded(otp));
      },
    );
  }

  Future<void> _onGetEndGeneratedOtp(
    GetEndGeneratedOtpEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Getting generated End Trip OTP');
    emit(const EndTripOtpLoading());
    
    final result = await _getGeneratedEndTripOtp();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get End Trip OTP: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (generatedOtp) {
        debugPrint('✅ End Trip OTP generated successfully');
        emit(EndTripOtpLoaded(generatedOtp: generatedOtp));
      },
    );
  }

  Future<void> _onVerifyEndTripOtp(
    VerifyEndTripOtpEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Verifying End Trip OTP');
    emit(const EndTripOtpLoading());
    
    final result = await _verifyEndTripOtp(
      EndOTPVerifyParams(
        enteredOtp: event.enteredOtp,
        generatedOtp: event.generatedOtp,
        tripId: event.tripId,
        otpId: event.otpId,
        odometerReading: event.odometerReading,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ End Trip OTP verification failed: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (isVerified) {
        debugPrint('✅ End Trip OTP verification complete: $isVerified');
        emit(EndTripOtpVerified(
          isVerified: isVerified,
          otpType: 'endTrip',
          odometerReading: event.odometerReading,
        ));
      },
    );
  }

  Future<void> _onGetAllEndTripOtps(
    GetAllEndTripOtpsEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Getting all End Trip OTPs');
    emit(const EndTripOtpLoading());
    
    final result = await _getAllEndTripOtps();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all End Trip OTPs: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (otps) {
        debugPrint('✅ Successfully retrieved ${otps.length} End Trip OTPs');
        emit(AllEndTripOtpsLoaded(otps));
      },
    );
  }

  Future<void> _onCreateEndTripOtp(
    CreateEndTripOtpEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Creating new End Trip OTP');
    emit(const EndTripOtpLoading());
    
    final result = await _createEndTripOtp(
      CreateEndTripOtpParams(
        otpCode: event.otpCode,
        tripId: event.tripId,
        generatedCode: event.generatedCode,
        endTripOdometer: event.endTripOdometer,
        isVerified: event.isVerified,
        verifiedAt: event.verifiedAt,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to create End Trip OTP: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ Successfully created End Trip OTP with ID: ${otp.id}');
        emit(EndTripOtpCreated(otp));
      },
    );
  }

  Future<void> _onUpdateEndTripOtp(
    UpdateEndTripOtpEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Updating End Trip OTP: ${event.id}');
    emit(const EndTripOtpLoading());
    
    final result = await _updateEndTripOtp(
      UpdateEndTripOtpParams(
        id: event.id,
        otpCode: event.otpCode,
        tripId: event.tripId,
        generatedCode: event.generatedCode,
        endTripOdometer: event.endTripOdometer,
        isVerified: event.isVerified,
        verifiedAt: event.verifiedAt,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to update End Trip OTP: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (otp) {
        debugPrint('✅ Successfully updated End Trip OTP: ${otp.id}');
        emit(EndTripOtpUpdated(otp));
      },
    );
  }

  Future<void> _onDeleteEndTripOtp(
    DeleteEndTripOtpEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Deleting End Trip OTP: ${event.id}');
    emit(const EndTripOtpLoading());
    
    final result = await _deleteEndTripOtp(event.id);
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete End Trip OTP: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted End Trip OTP');
        emit(EndTripOtpDeleted(event.id));
      },
    );
  }

  Future<void> _onDeleteAllEndTripOtps(
    DeleteAllEndTripOtpsEvent event,
    Emitter<EndTripOtpState> emit,
  ) async {
    debugPrint('🔄 Deleting multiple End Trip OTPs: ${event.ids.length} items');
    emit(const EndTripOtpLoading());
    
    final result = await _deleteAllEndTripOtps(
      DeleteAllEndTripOtpsParams(ids: event.ids),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete multiple End Trip OTPs: ${failure.message}');
        emit(EndTripOtpError(message: failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all End Trip OTPs');
        emit(AllEndTripOtpsDeleted(event.ids));
      },
    );
  }
}
