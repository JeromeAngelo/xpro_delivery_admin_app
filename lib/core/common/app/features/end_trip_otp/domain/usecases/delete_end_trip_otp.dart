import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteEndTripOtp implements UsecaseWithParams<bool, String> {
  final EndTripOtpRepo _repo;

  const DeleteEndTripOtp(this._repo);

  @override
  ResultFuture<bool> call(String id) => _repo.deleteEndTripOtp(id);
}
