import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class UserTripCollectionRepo {
  const UserTripCollectionRepo();

  // Get all trip collections for a specific user
  ResultFuture<List<UserTripCollectionEntity>> getUserTripCollections(String userId);
  
}
