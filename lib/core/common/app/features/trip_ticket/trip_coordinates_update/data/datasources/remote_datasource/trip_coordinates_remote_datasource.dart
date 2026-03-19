import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip_coordinates_update/data/model/trip_coordinates_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

abstract class TripCoordinatesRemoteDataSource {
  
  Future<List<TripCoordinatesModel>> getTripCoordinatesByTripId(
    String tripId, {
    int delayBeforeFetch = 3,
  });
}

class TripCoordinatesRemoteDataSourceImpl
    implements TripCoordinatesRemoteDataSource {
   TripCoordinatesRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
Future<List<TripCoordinatesModel>> getTripCoordinatesByTripId(
  String tripId, {
  int delayBeforeFetch = 3,
}) async {
  try {
    final String actualTripId = _extractTripId(tripId);

    _log(
      '🔄 Getting trip coordinates for trip ID: $actualTripId (waiting ${delayBeforeFetch}s for latest data)',
    );

    if (delayBeforeFetch > 0) {
      await Future.delayed(Duration(seconds: delayBeforeFetch));
    }

    _log('✅ Delay complete, now fetching coordinates for trip: $actualTripId');

    final List<RecordModel> records = await _pocketBaseClient
        .collection('tripCoordinatesUpdates')
        .getFullList(
          filter: 'trip = "$actualTripId"',
          expand: 'trip',
          sort: '-created',
        );

    _log(
      '✅ Retrieved ${records.length} coordinate updates for trip: $actualTripId',
    );

    return records.map((record) {
      final TripModel? tripModel = _extractTripModel(record);
      final double? latitude = _toDouble(record.data['latitude']);
      final double? longitude = _toDouble(record.data['longitude']);

      return TripCoordinatesModel(
        id: record.id,
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        trip: tripModel,
        tripId: actualTripId,
        latitude: latitude,
        longitude: longitude,
        created: _parseDate(record.created),
        updated: _parseDate(record.updated),
      );
    }).toList(growable: false);
  } catch (e) {
    debugPrint('❌ Error getting trip coordinates: ${e.toString()}');
    throw ServerException(
      message: 'Failed to load trip coordinates: ${e.toString()}',
      statusCode: '500',
    );
  }
}

String _extractTripId(String tripId) {
  if (tripId.isNotEmpty && tripId.codeUnitAt(0) == 123) {
    // 123 == '{'
    final dynamic tripData = jsonDecode(tripId);
    return tripData['id']?.toString() ?? tripId;
  }
  return tripId;
}

TripModel? _extractTripModel(RecordModel record) {
  final expandData = record.expand;
  if (!expandData.containsKey('trip')) return null;

  final tripData = expandData['trip'];
  if (tripData is List && tripData!.isNotEmpty) {
    final firstRecord = tripData.first;
    return TripModel.fromJson({
      'id': firstRecord.id,
      'collectionId': firstRecord.collectionId,
      'collectionName': firstRecord.collectionName,
      ...firstRecord.data,
    });
  }

  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

void _log(String message) {
  assert(() {
    debugPrint(message);
    return true;
  }());
}

final RegExp _unixTimestampRegExp = RegExp(r'^\d+$');
final RegExp _mmDdYyyyRegExp = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
final RegExp _yyyyMmDdRegExp = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
final RegExp _ddMmYyyyDashRegExp = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$');
final RegExp _ddMmYyyyDotRegExp = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$');
final RegExp _yyyyMmDdSlashRegExp = RegExp(r'^(\d{4})\/(\d{1,2})\/(\d{1,2})$');

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  final String strValue = value.toString().trim();
  if (strValue.isEmpty) return null;

  try {
    return DateTime.parse(strValue);
  } catch (_) {
    // continue
  }

  try {
    if (strValue.length >= 10 && _unixTimestampRegExp.hasMatch(strValue)) {
      int timestamp = int.parse(strValue);
      if (strValue.length == 10) {
        timestamp *= 1000;
      }
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    Match? match;

    match = _mmDdYyyyRegExp.firstMatch(strValue);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
      );
    }

    match = _yyyyMmDdRegExp.firstMatch(strValue);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }

    match = _ddMmYyyyDashRegExp.firstMatch(strValue);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    }

    match = _ddMmYyyyDotRegExp.firstMatch(strValue);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    }

    match = _yyyyMmDdSlashRegExp.firstMatch(strValue);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }

    final List<String> isoVariations = [
      strValue.replaceAll(' ', 'T'),
      '${strValue}T00:00:00.000Z',
      '${strValue}Z',
    ];

    for (final variation in isoVariations) {
      try {
        return DateTime.parse(variation);
      } catch (_) {
        // continue
      }
    }

    return DateTime.now();
  } catch (_) {
    return DateTime.now();
  }
}
}
