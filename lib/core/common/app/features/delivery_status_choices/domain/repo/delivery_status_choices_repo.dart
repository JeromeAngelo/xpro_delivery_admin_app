import '../../../../../../typedefs/typedefs.dart';
import '../entity/delivery_status_choices_entity.dart';

abstract class DeliveryStatusChoicesRepo {
  const DeliveryStatusChoicesRepo();

  ResultFuture<List<DeliveryStatusChoicesEntity>>
  getAllAssignedDeliveryStatusChoices(String customerId);
  ResultFuture<void> updateDeliveryStatus(
    String deliveryDataId,
    DeliveryStatusChoicesEntity status,
  );
}
