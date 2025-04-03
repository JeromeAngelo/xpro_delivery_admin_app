import 'package:desktop_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllOtps implements UsecaseWithoutParams<List<OtpEntity>> {
  final OtpRepo _repo;

  const GetAllOtps(this._repo);

  @override
  ResultFuture<List<OtpEntity>> call() => _repo.getAllOtps();
}
