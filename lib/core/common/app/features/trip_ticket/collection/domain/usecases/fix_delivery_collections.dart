import 'package:flutter/foundation.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/collection/domain/repo/collection_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class FixDeliveryCollections
    extends UsecaseWithoutParams<List<CollectionEntity>> {
  FixDeliveryCollections({required CollectionRepo collectionRepo})
    : _collectionRepo = collectionRepo;

  final CollectionRepo _collectionRepo;

  @override
  ResultFuture<List<CollectionEntity>> call() async {
    debugPrint('🔧 FIX: Starting fix delivery collections via repo');
    return _collectionRepo.fixDeliveryCollections();
  }
}
