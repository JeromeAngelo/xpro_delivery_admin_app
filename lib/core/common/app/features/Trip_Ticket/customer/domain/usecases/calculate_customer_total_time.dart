
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class CalculateCustomerTotalTime extends UsecaseWithParams<String, String> {
  const CalculateCustomerTotalTime(this._repo);

  final CustomerRepo _repo;

  @override
  ResultFuture<String> call(String params) => _repo.calculateCustomerTotalTime(params);
}
