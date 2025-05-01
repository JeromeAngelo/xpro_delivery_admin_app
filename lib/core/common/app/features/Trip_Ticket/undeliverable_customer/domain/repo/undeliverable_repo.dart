import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/undeliverable_reason.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class UndeliverableRepo {
  const UndeliverableRepo();

  // Get undeliverable customers for a specific trip
  ResultFuture<List<UndeliverableCustomerEntity>> getUndeliverableCustomers(String tripId);
  
  // Get a specific undeliverable customer by ID
  ResultFuture<UndeliverableCustomerEntity> getUndeliverableCustomerById(String customerId);
  
  // Get all undeliverable customers
  ResultFuture<List<UndeliverableCustomerEntity>> getAllUndeliverableCustomers();
  
  // Create a new undeliverable customer
  ResultFuture<UndeliverableCustomerEntity> createUndeliverableCustomer(
    UndeliverableCustomerEntity undeliverableCustomer,
    String customerId,
  );
  
  // Update an existing undeliverable customer
  ResultFuture<UndeliverableCustomerEntity> updateUndeliverableCustomer(
    UndeliverableCustomerEntity undeliverableCustomer,
    String customerId,
  );
  
  // Delete a specific undeliverable customer
  ResultFuture<bool> deleteUndeliverableCustomer(String undeliverableCustomerId);
  
  // Delete all undeliverable customers
  ResultFuture<bool> deleteAllUndeliverableCustomers();
  
  // Set the reason for an undeliverable customer
  ResultFuture<UndeliverableCustomerEntity> setUndeliverableReason(
    String customerId, 
    UndeliverableReason reason
  );
}
