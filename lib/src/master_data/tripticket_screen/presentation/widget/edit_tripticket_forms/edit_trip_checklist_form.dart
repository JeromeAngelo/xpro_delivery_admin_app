import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/data/model/checklist_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_state.dart';

class EditTripChecklistForm extends StatefulWidget {
  final TripEntity? currentTrip;
  final List<ChecklistModel> selectedChecklists;
  final ValueChanged<List<ChecklistModel>> onChecklistsChanged;

  const EditTripChecklistForm({
    super.key,
    required this.currentTrip,
    required this.selectedChecklists,
    required this.onChecklistsChanged,
  });

  @override
  State<EditTripChecklistForm> createState() => _EditTripChecklistFormState();
}

class _EditTripChecklistFormState extends State<EditTripChecklistForm> {
  List<ChecklistModel> _availableChecklists = [];
  List<ChecklistModel> _currentSelectedChecklists = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklistData();
    _initializeWithExistingData();
  }

  void _initializeWithExistingData() {
    // Initialize with existing trip checklist data
    if (widget.currentTrip?.checklist != null &&
        widget.currentTrip!.checklist.isNotEmpty) {
      _currentSelectedChecklists =
          widget.currentTrip!.checklist
              .map(
                (checklist) => ChecklistModel(
                  id: checklist.id,
                  objectName: checklist.objectName,
                  status: checklist.status,
                  isChecked: checklist.isChecked,
                  timeCompleted: checklist.timeCompleted,
                ),
              )
              .toList();

      // Notify parent immediately
      widget.onChecklistsChanged(_currentSelectedChecklists);
    }
  }

  void _loadChecklistData() {
    context.read<ChecklistBloc>().add(const GetAllChecklistsEvent());
  }

  void _addChecklist(ChecklistModel checklist) {
    setState(() {
      _currentSelectedChecklists.add(checklist);
    });
    widget.onChecklistsChanged(_currentSelectedChecklists);
  }

  void _removeChecklist(ChecklistModel checklist) {
    setState(() {
      _currentSelectedChecklists.removeWhere((item) => item.id == checklist.id);
    });
    widget.onChecklistsChanged(_currentSelectedChecklists);
  }

  bool _isChecklistSelected(ChecklistModel checklist) {
    return _currentSelectedChecklists.any((item) => item.id == checklist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Trip Checklist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showChecklistSelectionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Checklist'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Checklists Display
            if (_currentSelectedChecklists.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.checklist_rtl, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No checklists selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Click "Add Checklist" to add checklist items to this trip',
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
                  itemCount: _currentSelectedChecklists.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final checklist = _currentSelectedChecklists[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            checklist.isChecked == true
                                ? Colors.green.shade100
                                : Colors.purple.shade100,
                        child: Icon(
                          checklist.isChecked == true
                              ? Icons.check_circle
                              : Icons.checklist_rtl,
                          color:
                              checklist.isChecked == true
                                  ? Colors.green.shade800
                                  : Colors.purple.shade800,
                        ),
                      ),
                      title: Text(
                        checklist.objectName ?? 'Unknown Checklist',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (checklist.status != null)
                            Text(
                              checklist.status!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      checklist.isChecked == true
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                ),
                                child: Text(
                                  checklist.isChecked == true
                                      ? 'Completed'
                                      : 'Pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        checklist.isChecked == true
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeChecklist(checklist),
                        tooltip: 'Remove from trip',
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Selected ${_currentSelectedChecklists.length} checklist item(s) for this trip',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
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

  void _showChecklistSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<ChecklistBloc, ChecklistState>(
          builder: (context, state) {
            if (state is ChecklistLoading) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (state is ChecklistLoaded) {
              _availableChecklists =
                  state.checklist
                      .map((entity) => ChecklistModel.fromEntity(entity))
                      .toList();

              final availableForSelection =
                  _availableChecklists
                      .where((checklist) => !_isChecklistSelected(checklist))
                      .toList();

              return AlertDialog(
                title: const Text('Select Checklist Items'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child:
                      availableForSelection.isEmpty
                          ? const Center(
                            child: Text(
                              'No additional checklist items available',
                            ),
                          )
                          : ListView.builder(
                            itemCount: availableForSelection.length,
                            itemBuilder: (context, index) {
                              final checklist = availableForSelection[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      checklist.isChecked == true
                                          ? Colors.green.shade100
                                          : Colors.purple.shade100,
                                  child: Icon(
                                    checklist.isChecked == true
                                        ? Icons.check_circle
                                        : Icons.checklist_rtl,
                                    color:
                                        checklist.isChecked == true
                                            ? Colors.green.shade800
                                            : Colors.purple.shade800,
                                  ),
                                ),
                                title: Text(
                                  checklist.objectName ?? 'Unknown Checklist',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (checklist.status != null)
                                      Text(
                                        checklist.status!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color:
                                                checklist.isChecked == true
                                                    ? Colors.green.shade100
                                                    : Colors.orange.shade100,
                                          ),
                                          child: Text(
                                            checklist.isChecked == true
                                                ? 'Completed'
                                                : 'Pending',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  checklist.isChecked == true
                                                      ? Colors.green.shade800
                                                      : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _addChecklist(checklist);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Add'),
                                ),
                              );
                            },
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            } else if (state is ChecklistError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load checklists: ${state.message}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: Text('No checklist data available')),
              ),
            );
          },
        );
      },
    );
  }
}
