import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class ChecklistRepo {
  // Get all checklists
  ResultFuture<List<ChecklistEntity>> getAllChecklists();
  
  
  
  // Load checklists by trip ID
  ResultFuture<List<ChecklistEntity>> loadChecklistByTripId(String? tripId);
  
  // Check/update a specific checklist item
  ResultFuture<bool> checkItem(String id);
  
  // Create a new checklist item
  ResultFuture<ChecklistEntity> createChecklistItem({
    required String objectName,
    required bool isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  });
  
  // Update an existing checklist item
  ResultFuture<ChecklistEntity> updateChecklistItem({
    required String id,
    String? objectName,
    bool? isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  });
  
  // Delete a single checklist item
  ResultFuture<bool> deleteChecklistItem(String id);
  
  // Delete multiple checklist items
  ResultFuture<bool> deleteAllChecklistItems(List<String> ids);
}
