import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/models/personel_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_state.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/personnel_selection_dialog.dart';

class EditTripPersonnelForm extends StatefulWidget {
  final TripEntity? currentTrip;
  final String? tripId;
  final List<PersonelModel> selectedPersonnel;
  final ValueChanged<List<PersonelModel>> onPersonnelChanged;

  const EditTripPersonnelForm({
    super.key,
    required this.currentTrip,
    this.tripId,
    required this.selectedPersonnel,
    required this.onPersonnelChanged,
  });

  @override
  State<EditTripPersonnelForm> createState() => _EditTripPersonnelFormState();
}

class _EditTripPersonnelFormState extends State<EditTripPersonnelForm> {
  List<PersonelModel> _availablePersonnel = [];
  List<PersonelModel> _currentSelectedPersonnel = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTripPersonnelData();
    _loadAllPersonnelData();
  }

  void _loadTripPersonnelData() {
    // Load personnel data specific to this trip
    final tripIdToUse = widget.tripId ?? widget.currentTrip?.id;
    if (tripIdToUse != null) {
      context.read<PersonelBloc>().add(LoadPersonelsByTripIdEvent(tripIdToUse));
      debugPrint('🔄 Loading personnel for trip ID: $tripIdToUse');
    } else {
      // Fallback to existing data if no trip ID available
      _initializeWithExistingData();
    }
  }

  void _loadAllPersonnelData() {
    // Load all available personnel for potential addition
    context.read<PersonelBloc>().add(GetPersonelEvent());
    debugPrint('📦 Loading all personnel for selection dialog');
  }

  void _initializeWithExistingData() {
    // Fallback initialization with existing trip personnel data
    if (widget.currentTrip?.personels != null &&
        widget.currentTrip!.personels.isNotEmpty) {
      _currentSelectedPersonnel =
          widget.currentTrip!.personels
              .map(
                (personnel) => PersonelModel(
                  id: personnel.id,
                  name: personnel.name,
                  role: personnel.role,
                  deliveryTeamModel: personnel.deliveryTeam,
                  created: personnel.created,
                  updated: personnel.updated,
                ),
              )
              .toList();

      // Notify parent immediately
      widget.onPersonnelChanged(_currentSelectedPersonnel);

      debugPrint(
        '👥 Initialized edit form with ${_currentSelectedPersonnel.length} existing personnel',
      );
    }
  }

  void _removePersonnel(PersonelModel personnel) {
    setState(() {
      _currentSelectedPersonnel.removeWhere((item) => item.id == personnel.id);
    });
    widget.onPersonnelChanged(_currentSelectedPersonnel);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonelBloc, PersonelState>(
      listener: (context, state) {
        if (state is PersonelLoaded) {
          setState(() {
            _availablePersonnel =
                state.personel
                    .map((entity) => PersonelModel.fromEntity(entity))
                    .toList();
          });
          debugPrint(
            '📦 Loaded ${_availablePersonnel.length} available personnel for selection',
          );
        } else if (state is PersonelsByTripLoaded) {
          // Handle trip-specific personnel data
          _currentSelectedPersonnel =
              state.personel
                  .map((entity) => PersonelModel.fromEntity(entity))
                  .toList();

          setState(() {
            _isLoading = false;
          });

          // Notify parent immediately
          widget.onPersonnelChanged(_currentSelectedPersonnel);

          debugPrint(
            '🔄 Loaded ${_currentSelectedPersonnel.length} trip personnel from BLoC',
          );
        } else if (state is PersonelError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading personnel: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Handle loading state
        bool isLoading = _isLoading;
        if (state is PersonelLoading) {
          isLoading = true;
        }

        return _buildContent(isLoading);
      },
    );
  }

  Widget _buildContent(bool isLoading) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Trip Personnel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed:
                      (_currentSelectedPersonnel.length < 3 && !isLoading)
                          ? _showPersonnelSelectionDialog
                          : null,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Personnel'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Personnel Display
            if (isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_currentSelectedPersonnel.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No personnel selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Click "Add Personnel" to assign personnel to this trip',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _currentSelectedPersonnel.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final personnel = _currentSelectedPersonnel[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          (personnel.name ?? 'U').substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      title: Text(
                        personnel.name ?? 'Unknown Personnel',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (personnel.role != null)
                            Text(
                              'Role: ${personnel.role.toString().split('.').last}',
                            ),
                          if (personnel.deliveryTeam?.id != null)
                            Text('Team ID: ${personnel.deliveryTeam!.id}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removePersonnel(personnel),
                        tooltip: 'Remove from trip',
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Summary and Constraints
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _currentSelectedPersonnel.length < 3
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _currentSelectedPersonnel.length < 3
                          ? Colors.blue.shade200
                          : Colors.green.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _currentSelectedPersonnel.length < 3
                            ? Icons.info_outline
                            : Icons.check_circle_outline,
                        color:
                            _currentSelectedPersonnel.length < 3
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected ${_currentSelectedPersonnel.length} of 3 maximum personnel',
                        style: TextStyle(
                          color:
                              _currentSelectedPersonnel.length < 3
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_currentSelectedPersonnel.isEmpty)
                    const SizedBox(height: 8),
                  if (_currentSelectedPersonnel.isEmpty)
                    Text(
                      'At least 1 personnel is required for the trip',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPersonnelSelectionDialog() {
    // Check if we have available personnel loaded
    if (_availablePersonnel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading personnel data, please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => PersonnelSelectionDialog(
            availablePersonnel: _availablePersonnel,
            selectedPersonnel: _currentSelectedPersonnel,
            onPersonnelChanged: (selectedPersonnel) {
              // Check maximum limit
              if (selectedPersonnel.length > 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maximum of 3 personnel allowed per trip'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              setState(() {
                _currentSelectedPersonnel = selectedPersonnel;
              });

              // Notify parent about the change
              widget.onPersonnelChanged(_currentSelectedPersonnel);

              debugPrint(
                '📝 Updated personnel selection: ${_currentSelectedPersonnel.length} personnel selected',
              );
            },
          ),
    );
  }
}
