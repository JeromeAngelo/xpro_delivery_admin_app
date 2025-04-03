import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class DeleteAllEndTripOtps implements UsecaseWithParams<bool, DeleteAllEndTripOtpsParams> {
  final EndTripOtpRepo _repo;

  const DeleteAllEndTripOtps(this._repo);

  @override
  ResultFuture<bool> call(DeleteAllEndTripOtpsParams params) => 
      _repo.deleteAllEndTripOtps(params.ids);
}

class DeleteAllEndTripOtpsParams extends Equatable {
  final List<String> ids;

  const DeleteAllEndTripOtpsParams({required this.ids});

  @override
  List<Object> get props => [ids];
}
