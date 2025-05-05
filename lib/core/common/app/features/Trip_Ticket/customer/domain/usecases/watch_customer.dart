import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';

class WatchCustomers {
  const WatchCustomers(this._repo);
  final CustomerRepo _repo;

  Stream<Either<Failure, List<CustomerEntity>>> call(String tripId) => 
      _repo.watchCustomers(tripId);
}
