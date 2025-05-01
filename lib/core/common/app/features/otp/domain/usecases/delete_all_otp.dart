import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class DeleteAllOtps implements UsecaseWithParams<bool, DeleteAllOtpsParams> {
  final OtpRepo _repo;

  const DeleteAllOtps(this._repo);

  @override
  ResultFuture<bool> call(DeleteAllOtpsParams params) => 
      _repo.deleteAllOtps(params.ids);
}

class DeleteAllOtpsParams extends Equatable {
  final List<String> ids;

  const DeleteAllOtpsParams({required this.ids});

  @override
  List<Object> get props => [ids];
}
