import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateCustomer extends UsecaseWithParams<CustomerEntity, UpdateCustomerParams> {
  final CustomerRepo _repo;
  const UpdateCustomer(this._repo);

  @override
  ResultFuture<CustomerEntity> call(UpdateCustomerParams params) => 
      _repo.updateCustomer(
        id: params.id,
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

class UpdateCustomerParams extends Equatable {
  final String id;
  final String? deliveryNumber;
  final String? storeName;
  final String? ownerName;
  final List<String>? contactNumber;
  final String? address;
  final String? municipality;
  final String? province;
  final String? modeOfPayment;
  final String? tripId;
  final String? totalAmount;
  final String? latitude;
  final String? longitude;
  final String? notes;
  final String? remarks;
  final bool? hasNotes;
  final double? confirmedTotalPayment;

  const UpdateCustomerParams({
    required this.id,
    this.deliveryNumber,
    this.storeName,
    this.ownerName,
    this.contactNumber,
    this.address,
    this.municipality,
    this.province,
    this.modeOfPayment,
    this.tripId,
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
    id,
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
