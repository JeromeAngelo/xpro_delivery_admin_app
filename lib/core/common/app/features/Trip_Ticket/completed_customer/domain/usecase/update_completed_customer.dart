import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateCompletedCustomer extends UsecaseWithParams<CompletedCustomerEntity, UpdateCompletedCustomerParams> {
  final CompletedCustomerRepo _repo;
  const UpdateCompletedCustomer(this._repo);

  @override
  ResultFuture<CompletedCustomerEntity> call(UpdateCompletedCustomerParams params) => 
      _repo.updateCompletedCustomer(
        id: params.id,
        deliveryNumber: params.deliveryNumber,
        storeName: params.storeName,
        ownerName: params.ownerName,
        contactNumber: params.contactNumber,
        address: params.address,
        municipality: params.municipality,
        province: params.province,
        modeOfPayment: params.modeOfPayment,
        timeCompleted: params.timeCompleted,
        totalAmount: params.totalAmount,
        totalTime: params.totalTime,
        tripId: params.tripId,
        transactionId: params.transactionId,
        customerId: params.customerId,
      );
}

class UpdateCompletedCustomerParams extends Equatable {
  final String id;
  final String? deliveryNumber;
  final String? storeName;
  final String? ownerName;
  final List<String>? contactNumber;
  final String? address;
  final String? municipality;
  final String? province;
  final String? modeOfPayment;
  final DateTime? timeCompleted;
  final double? totalAmount;
  final String? totalTime;
  final String? tripId;
  final String? transactionId;
  final String? customerId;

  const UpdateCompletedCustomerParams({
    required this.id,
    this.deliveryNumber,
    this.storeName,
    this.ownerName,
    this.contactNumber,
    this.address,
    this.municipality,
    this.province,
    this.modeOfPayment,
    this.timeCompleted,
    this.totalAmount,
    this.totalTime,
    this.tripId,
    this.transactionId,
    this.customerId,
  });

  @override
  List<Object?> get props => [
    id,
    deliveryNumber,
    storeName,
    ownerName,
    contactNumber,
    address,
    municipality,
    province,
    modeOfPayment,
    timeCompleted,
    totalAmount,
    totalTime,
    tripId,
    transactionId,
    customerId,
  ];
}
