import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateCustomer extends UsecaseWithParams<CustomerEntity, CreateCustomerParams> {
  final CustomerRepo _repo;
  const CreateCustomer(this._repo);

  @override
  ResultFuture<CustomerEntity> call(CreateCustomerParams params) => 
      _repo.createCustomer(
        deliveryNumber: params.deliveryNumber,
        storeName: params.storeName,
        ownerName: params.ownerName,
        contactNumber: params.contactNumber,
        address: params.address,
        municipality: params.municipality,
        province: params.province,
        modeOfPayment: params.modeOfPayment,
        tripId: params.tripId,
        totalAmount: params.totalAmount,
        latitude: params.latitude,
        longitude: params.longitude,
        notes: params.notes,
        remarks: params.remarks,
        hasNotes: params.hasNotes,
        confirmedTotalPayment: params.confirmedTotalPayment,
      );
}

class CreateCustomerParams extends Equatable {
  final String deliveryNumber;
  final String storeName;
  final String ownerName;
  final List<String> contactNumber;
  final String address;
  final String municipality;
  final String province;
  final String modeOfPayment;
  final String tripId;
  final String? totalAmount;
  final String? latitude;
  final String? longitude;
  final String? notes;
  final String? remarks;
  final bool? hasNotes;
  final double? confirmedTotalPayment;

  const CreateCustomerParams({
    required this.deliveryNumber,
    required this.storeName,
    required this.ownerName,
    required this.contactNumber,
    required this.address,
    required this.municipality,
    required this.province,
    required this.modeOfPayment,
    required this.tripId,
    this.totalAmount,
    this.latitude,
    this.longitude,
    this.notes,
    this.remarks,
    this.hasNotes,
    this.confirmedTotalPayment,
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
    tripId,
    totalAmount,
    latitude,
    longitude,
    notes,
    remarks,
    hasNotes,
    confirmedTotalPayment,
  ];
}
