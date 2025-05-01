import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllEndTripOtps implements UsecaseWithoutParams<List<EndTripOtpEntity>> {
  final EndTripOtpRepo _repo;

  const GetAllEndTripOtps(this._repo);

  @override
  ResultFuture<List<EndTripOtpEntity>> call() => _repo.getAllEndTripOtps();
}
