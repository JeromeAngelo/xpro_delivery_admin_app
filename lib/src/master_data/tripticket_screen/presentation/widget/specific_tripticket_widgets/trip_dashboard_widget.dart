import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TripDashboardWidget extends StatefulWidget {
  final TripEntity trip;

  const TripDashboardWidget({super.key, required this.trip});

  @override
  State<TripDashboardWidget> createState() => _TripDashboardWidgetState();
}

class _TripDashboardWidgetState extends State<TripDashboardWidget> {
  bool _isQrExpanded = false;
  bool _isQrVisible = true;

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) {
      if (date == null) return 'Not set';
      return DateFormat('MM/dd/yyyy hh:mm a').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QR Code Display Section
        if (widget.trip.qrCode != null && widget.trip.qrCode!.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Column(
              children: [
                // Header with toggle buttons
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Trip QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Toggle visibility button
                      IconButton(
                        icon: Icon(
                          _isQrVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        tooltip: _isQrVisible ? 'Hide QR Code' : 'Show QR Code',
                        onPressed: () {
                          setState(() {
                            _isQrVisible = !_isQrVisible;
                          });
                        },
                      ),
                      // Toggle size button
                      IconButton(
                        icon: Icon(
                          _isQrExpanded ? Icons.compress : Icons.expand,
                        ),
                        tooltip:
                            _isQrExpanded
                                ? 'Minimize QR Code'
                                : 'Maximize QR Code',
                        onPressed: () {
                          setState(() {
                            _isQrExpanded = !_isQrExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // QR Code content (conditionally visible)
                if (_isQrVisible)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // QR Code
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: QrImageView(
                            data: widget.trip.qrCode!,
                            version: QrVersions.auto,
                            size: _isQrExpanded ? 250 : 150,
                            backgroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 24),

                        // QR Code Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QR Code Value: ${widget.trip.qrCode}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scan this QR code with the X-Pro Delivery mobile app to quickly access this trip.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.print),
                                    label: const Text('Print QR Code'),
                                    onPressed: () {
                                      // Implement printing functionality
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Print functionality will be implemented soon',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.save_alt),
                                    label: const Text('Save as Image'),
                                    onPressed: () {
                                      // Implement save functionality
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Save functionality will be implemented soon',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        // Original Dashboard Summary
        DashboardSummary(
          items: [
            DashboardInfoItem(
              icon: Icons.numbers,
              value: widget.trip.tripNumberId ?? 'N/A',
              label: 'Trip Number',
            ),
            DashboardInfoItem(
              icon: Icons.people,
              value: widget.trip.customers.length.toString(),
              label: 'Customers',
            ),
            DashboardInfoItem(
              icon: Icons.receipt,
              value: widget.trip.invoices.length.toString(),
              label: 'Invoices',
            ),
            DashboardInfoItem(
              icon: Icons.play_circle_filled,
              value: formatDate(widget.trip.timeAccepted),
              label: 'Start of Trip',
            ),
            DashboardInfoItem(
              icon: Icons.stop_circle,
              value: formatDate(widget.trip.timeEndTrip),
              label: 'End of Trip',
            ),
            DashboardInfoItem(
              icon: Icons.check_circle,
              value: widget.trip.completedCustomers.length.toString(),
              label: 'Completed Deliveries',
            ),
            DashboardInfoItem(
              icon: Icons.cancel,
              value: widget.trip.undeliverableCustomers.length.toString(),
              label: 'Undelivered',
            ),
            DashboardInfoItem(
              icon: Icons.route,
              value: widget.trip.totalTripDistance ?? '0 km',
              label: 'Total Distance in KM',
            ),
          ],
        ),
      ],
    );
  }
}
