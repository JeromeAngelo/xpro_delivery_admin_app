import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/entity/delivery_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateDeliveryUpdate extends UsecaseWithParams<DeliveryUpdateEntity, UpdateDeliveryUpdateParams> {
  final DeliveryUpdateRepo _repo;
  const UpdateDeliveryUpdate(this._repo);

  @override
  ResultFuture<DeliveryUpdateEntity> call(UpdateDeliveryUpdateParams params) => 
      _repo.updateDeliveryUpdate(
        id: params.id,
        title: params.title,
        subtitle: params.subtitle,
        time: params.time,
        customerId: params.customerId,
        isAssigned: params.isAssigned,
        assignedTo: params.assignedTo,
        image: params.image,
        remarks: params.remarks,
      );
}

class UpdateDeliveryUpdateParams extends Equatable {
  final String id;
  final String? title;
  final String? subtitle;
  final DateTime? time;
  final String? customerId;
  final bool? isAssigned;
  final String? assignedTo;
  final String? image;
  final String? remarks;

  const UpdateDeliveryUpdateParams({
    required this.id,
    this.title,
    this.subtitle,
    this.time,
    this.customerId,
    this.isAssigned,
    this.assignedTo,
    this.image,
    this.remarks,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    time,
    customerId,
    isAssigned,
    assignedTo,
    image,
    remarks,
  ];
}
