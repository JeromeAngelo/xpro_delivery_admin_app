import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateCompletedCustomer extends UsecaseWithParams<CompletedCustomerEntity, CreateCompletedCustomerParams> {
  final CompletedCustomerRepo _repo;
  const CreateCompletedCustomer(this._repo);

  @override
  ResultFuture<CompletedCustomerEntity> call(CreateCompletedCustomerParams params) => 
      _repo.createCompletedCustomer(
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

class CreateCompletedCustomerParams extends Equatable {
  final String deliveryNumber;
  final String storeName;
  final String ownerName;
  final List<String> contactNumber;
  final String address;
  final String municipality;
  final String province;
  final String modeOfPayment;
  final DateTime timeCompleted;
  final double totalAmount;
  final String totalTime;
  final String tripId;
  final String? transactionId;
  final String? customerId;

  const CreateCompletedCustomerParams({
    required this.deliveryNumber,
    required this.storeName,
    required this.ownerName,
    required this.contactNumber,
    required this.address,
    required this.municipality,
    required this.province,
    required this.modeOfPayment,
    required this.timeCompleted,
    required this.totalAmount,
    required this.totalTime,
    required this.tripId,
    this.transactionId,
    this.customerId,
  });

  @override
  List<Object?> get props => [
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
