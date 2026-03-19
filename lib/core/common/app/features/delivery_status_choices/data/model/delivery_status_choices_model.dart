import 'package:flutter/material.dart';

import '../../domain/entity/delivery_status_choices_entity.dart';

class DeliveryStatusChoicesModel extends DeliveryStatusChoicesEntity {
  // --------------------------------------------------------------------------
  // CONSTRUCTOR
  // --------------------------------------------------------------------------
  DeliveryStatusChoicesModel({
   super.id,
    super.collectionId,
    super.collectionName,
    super.title,
    super.subtitle,
    super.created,
    super.updated,
  }); // initialize here

  // --------------------------------------------------------------------------
  // 🔵 PARSE HELPERS
  // --------------------------------------------------------------------------
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      debugPrint('📅 Failed to parse date → fallback: null');
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // 🔵 FROM JSON
  // --------------------------------------------------------------------------
  factory DeliveryStatusChoicesModel.fromJson(dynamic json) {
    return DeliveryStatusChoicesModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName:
          json['collectionName']?.toString() ?? 'delivery_status_choices',
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
     
    );
  }

  // --------------------------------------------------------------------------
  // 🔵 TO JSON
  // --------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'title': title,
      'subtitle': subtitle,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  // --------------------------------------------------------------------------
  // 🔵 INITIAL FACTORY
  // --------------------------------------------------------------------------
  factory DeliveryStatusChoicesModel.initial() {
    final now = DateTime.now();
    return DeliveryStatusChoicesModel(
      id: '',
      collectionId: '',
      collectionName: 'delivery_status_choices',
      title: '',
      subtitle: '',
      created: now,
      updated: now,
    );
  }

  // --------------------------------------------------------------------------
  // 🔵 COPY WITH
  // --------------------------------------------------------------------------
  DeliveryStatusChoicesModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? title,
    String? subtitle,
    DateTime? created,
    DateTime? updated,
    String? syncStatus,
    int? retryCount,
    DateTime? lastSyncAttemptAt,
    DateTime? nextRetryAt,
    String? lastSyncError,
    DateTime? lastLocalUpdatedAt,
  }) {
    return DeliveryStatusChoicesModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // --------------------------------------------------------------------------
  // 🔵 EQUALITY + HASH
  // --------------------------------------------------------------------------
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryStatusChoicesModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeliveryStatusChoicesModel(id: $id, title: $title, ';
  }
}
