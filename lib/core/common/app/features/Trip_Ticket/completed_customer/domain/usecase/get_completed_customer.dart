

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetCompletedCustomer extends UsecaseWithParams<List<CompletedCustomerEntity>, String> {
  final CompletedCustomerRepo _repo;
  const GetCompletedCustomer(this._repo);

  @override
  ResultFuture<List<CompletedCustomerEntity>> call(String params) => 
      _repo.getCompletedCustomers(params);
   
}




 



