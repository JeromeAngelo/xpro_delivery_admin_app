import 'package:flutter/material.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';

class CustomerTile extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback? onTap;
  final Color? borderColor;

  const CustomerTile({
    super.key,
    required this.customer,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor ?? Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store name with icon
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.storeName ?? 'Unknown Store',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    customer.trip?.tripNumberId ?? 'Unknown Store',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Delivery number
              Row(
                children: [
                  Icon(
                    Icons.numbers,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery #: ${customer.deliveryNumber ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatAddress(customer),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Invoice count and total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${customer.numberOfInvoices ?? 0} Invoice(s)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    '₱${customer.totalAmount}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(CustomerEntity customer) {
    final List<String> addressParts = [];

    if (customer.address != null && customer.address!.isNotEmpty) {
      addressParts.add(customer.address!);
    }

    if (customer.municipality != null && customer.municipality!.isNotEmpty) {
      addressParts.add(customer.municipality!);
    }

    if (customer.province != null && customer.province!.isNotEmpty) {
      addressParts.add(customer.province!);
    }

    return addressParts.join(', ');
  }
}
