
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class CreateDeliveryStatusParams {
  final String customerId;
  final String title;
  final String subtitle;
  final DateTime time;
  final bool isAssigned;
  final String image;

  const CreateDeliveryStatusParams({
    required this.customerId,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isAssigned,
    required this.image,
  });
}

class CreateDeliveryStatus extends UsecaseWithParams<void, CreateDeliveryStatusParams> {
  const CreateDeliveryStatus(this._repo);

  final DeliveryUpdateRepo _repo;

  @override
  ResultFuture<void> call(CreateDeliveryStatusParams params) => _repo.createDeliveryStatus(
        params.customerId,
        title: params.title,
        subtitle: params.subtitle,
        time: params.time,
        isAssigned: params.isAssigned,
        image: params.image,
      );
}
