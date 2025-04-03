import 'package:desktop_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteOtp implements UsecaseWithParams<bool, String> {
  final OtpRepo _repo;

  const DeleteOtp(this._repo);

  @override
  ResultFuture<bool> call(String id) => _repo.deleteOtp(id);
}
