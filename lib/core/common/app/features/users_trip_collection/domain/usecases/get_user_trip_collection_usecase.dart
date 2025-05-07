import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/repo/user_trip_collection_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetUserTripCollectionParams {
  final String userId;

  const GetUserTripCollectionParams({required this.userId});
}

class GetUserTripCollectionUsecase extends UsecaseWithParams<List<UserTripCollectionEntity>, GetUserTripCollectionParams> {
  final UserTripCollectionRepo _repo;

  const GetUserTripCollectionUsecase(this._repo);

  @override
  ResultFuture<List<UserTripCollectionEntity>> call(GetUserTripCollectionParams params) async {
    return _repo.getUserTripCollections(params.userId);
  }
}
