import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';

abstract class EndTripChecklistRepo {
  // Get all end trip checklists
  ResultFuture<List<EndChecklistEntity>> getAllEndTripChecklists();
  
  // Automatically generates checklist items for end trip
  ResultFuture<List<EndChecklistEntity>> generateEndTripChecklist(String tripId);
  
  // Checks/updates specific checklist item
  ResultFuture<bool> checkEndTripChecklistItem(String id);
  
  // Loads the generated checklist for viewing
  ResultFuture<List<EndChecklistEntity>> loadEndTripChecklist(String tripId);
  
  // Create a new end trip checklist item
  ResultFuture<EndChecklistEntity> createEndTripChecklistItem({
    required String objectName,
    required bool isChecked,
    required String tripId,
    String? status,
    DateTime? timeCompleted,
  });
  
  // Update an existing end trip checklist item
  ResultFuture<EndChecklistEntity> updateEndTripChecklistItem({
    required String id,
    String? objectName,
    bool? isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  });
  
  // Delete a single end trip checklist item
  ResultFuture<bool> deleteEndTripChecklistItem(String id);
  
  // Delete multiple end trip checklist items
  ResultFuture<bool> deleteAllEndTripChecklistItems(List<String> ids);
}
