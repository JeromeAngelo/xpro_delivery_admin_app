import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/repo/customer_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class CreateCustomerData extends UsecaseWithParams<CustomerDataEntity, CreateCustomerDataParams> {
  final CustomerDataRepo _repo;

  const CreateCustomerData(this._repo);

  @override
  ResultFuture<CustomerDataEntity> call(CreateCustomerDataParams params) async {
    return _repo.createCustomerData(
      name: params.name,
      refId: params.refId,
      province: params.province,
      municipality: params.municipality,
      barangay: params.barangay,
      longitude: params.longitude,
      latitude: params.latitude,
    );
  }
}

class CreateCustomerDataParams extends Equatable {
  final String name;
  final String refId;
  final String province;
  final String municipality;
  final String barangay;
  final double? longitude;
  final double? latitude;

  const CreateCustomerDataParams({
    required this.name,
    required this.refId,
    required this.province,
    required this.municipality,
    required this.barangay,
    this.longitude,
    this.latitude,
  });

  @override
  List<Object?> get props => [
        name,
        refId,
        province,
        municipality,
        barangay,
        longitude,
        latitude,
      ];
}
