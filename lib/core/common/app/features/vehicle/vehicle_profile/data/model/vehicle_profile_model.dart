import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../../../../../../enums/vehicle_status.dart';
import '../../../../delivery_team/personels/data/models/personel_models.dart';
import '../../../../general_auth/data/models/auth_models.dart';
import '../../../../place_lookups/municipality/data/model/municipality_model.dart';
import '../../../../place_lookups/municipality/domain/entity/municipality_entity.dart';
import '../../../../place_lookups/province/data/model/province_model.dart';
import '../../../../place_lookups/province/domain/entity/province_entity.dart';
import '../../../../place_lookups/region/data/model/region_model.dart';
import '../../../../place_lookups/region/domain/entity/region_entity.dart';
import '../../../../trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import '../../../../trip_ticket/trip/data/models/trip_models.dart';
import '../../domain/entity/vehicle_profile_entity.dart';

class VehicleProfileModel extends VehicleProfileEntity {
  String? pocketbaseId;

  // Relationship IDs
  String? deliveryVehicleId;
  List<String>? assignedTripIds;

  // Attachments stored in PocketBase
  List<String>? attachmentFiles;

  // Relationship IDs for assigned place lookups (multiple relations)
  List<String>? assignedRegionIds;
  List<String>? assignedProvinceIds;
  List<String>? assignedMunicipalityIds;

  VehicleProfileModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.deliveryVehicleData,
    super.assignedTrips,
    super.attachments,
    super.status,
    super.created,
    super.updated,
    this.deliveryVehicleId,
    this.assignedTripIds,
    super.yearModel,
    super.createdBy,
    super.designatedMunicipality,
    super.designatedProvince,
    super.remarks,
    super.driver,
    super.designatedRegion,
    this.attachmentFiles,
    super.assignedRegions,
    super.assignedProvinces,
    super.assignedMunicipalities,
    this.assignedRegionIds,
    this.assignedProvinceIds,
    this.assignedMunicipalityIds,
  }) : pocketbaseId = id ?? '';

  // ---------------------------------------------------------------------------
  // FROM JSON
  // ---------------------------------------------------------------------------
  factory VehicleProfileModel.fromJson(DataMap json) {
    final expand = json['expand'] as Map<String, dynamic>?;

    // DELIVERY VEHICLE
    DeliveryVehicleModel? deliveryVehicle;
    final dvData =
        expand?['deliveryVehicleData'] ?? json['deliveryVehicleData'];
    if (dvData != null) {
      if (dvData is RecordModel) {
        deliveryVehicle = DeliveryVehicleModel.fromJson({
          'id': dvData.id,
          'collectionId': dvData.collectionId,
          'collectionName': dvData.collectionName,
          ...dvData.data,
        });
      } else if (dvData is Map) {
        deliveryVehicle = DeliveryVehicleModel.fromJson(
          dvData as Map<String, dynamic>,
        );
      } else if (dvData is String) {
        deliveryVehicle = DeliveryVehicleModel(id: dvData);
      }
    }

    //Driver Data
    PersonelModel? driver;
    final driverData = expand?['driver'] ?? json['driver'];
    if (driverData != null) {
      if (driverData is RecordModel) {
        driver = PersonelModel.fromJson({
          'id': driverData.id,
          'collectionId': driverData.collectionId,
          'collectionName': driverData.collectionName,
          ...driverData.data,
        });
      } else if (driverData is Map) {
        driver = PersonelModel.fromJson(driverData as Map<String, dynamic>);
      } else if (driverData is String) {
        driver = PersonelModel(id: driverData);
      }
    }

    // CreatedBy Data
    GeneralUserModel? createdBy;
    final createdByData = expand?['createdBy'] ?? json['createdBy'];
    if (createdByData != null) {
      if (createdByData is RecordModel) {
        createdBy = GeneralUserModel.fromJson({
          'id': createdByData.id,
          'collectionId': createdByData.collectionId,
          'collectionName': createdByData.collectionName,
          ...createdByData.data,
        });
      } else if (createdByData is Map) {
        createdBy = GeneralUserModel.fromJson(
          createdByData as Map<String, dynamic>,
        );
      } else if (createdByData is String) {
        createdBy = GeneralUserModel(id: createdByData);
      }
    }

    // ASSIGNED TRIPS
    List<TripModel> assignedTripsList = [];
    final tripsExpand = expand?['assignedTrips'] ?? json['assignedTrips'];
    if (tripsExpand != null) {
      if (tripsExpand is List) {
        assignedTripsList =
            tripsExpand.map((t) {
              if (t is RecordModel) {
                return TripModel.fromJson({
                  'id': t.id,
                  'collectionId': t.collectionId,
                  'collectionName': t.collectionName,
                  ...t.data,
                });
              } else if (t is Map) {
                return TripModel.fromJson(t as Map<String, dynamic>);
              } else if (t is String) {
                return TripModel(id: t);
              }
              return TripModel.empty();
            }).toList();
      }
    }

    // ASSIGNED REGIONS (multiple relation → expand['assignedRegion'])
    List<RegionEntity> assignedRegionsList = [];
    final regionsExpand = expand?['assignedRegion'] ?? json['assignedRegion'];
    if (regionsExpand != null && regionsExpand is List) {
      for (final r in regionsExpand) {
        if (r is RecordModel) {
          assignedRegionsList.add(RegionModel.fromRecord(r));
        } else if (r is Map) {
          assignedRegionsList.add(
            RegionModel.fromJson(r as Map<String, dynamic>),
          );
        } else if (r is String) {
          assignedRegionsList.add(RegionEntity(id: r));
        }
      }
    }

    // ASSIGNED PROVINCES (multiple relation → expand['assignedProvince'])
    List<ProvinceEntity> assignedProvincesList = [];
    final provincesExpand =
        expand?['assignedProvince'] ?? json['assignedProvince'];
    if (provincesExpand != null && provincesExpand is List) {
      for (final p in provincesExpand) {
        if (p is RecordModel) {
          assignedProvincesList.add(ProvinceModel.fromRecord(p));
        } else if (p is Map) {
          assignedProvincesList.add(
            ProvinceModel.fromJson(p as Map<String, dynamic>),
          );
        } else if (p is String) {
          assignedProvincesList.add(ProvinceEntity(id: p));
        }
      }
    }

    // ASSIGNED MUNICIPALITIES (multiple relation → expand['assignedMunicipality'])
    List<MunicipalityEntity> assignedMunicipalitiesList = [];
    final municipalitiesExpand =
        expand?['assignedMunicipality'] ?? json['assignedMunicipality'];
    if (municipalitiesExpand != null && municipalitiesExpand is List) {
      for (final m in municipalitiesExpand) {
        if (m is RecordModel) {
          assignedMunicipalitiesList.add(MunicipalityModel.fromRecord(m));
        } else if (m is Map) {
          assignedMunicipalitiesList.add(
            MunicipalityModel.fromJson(m as Map<String, dynamic>),
          );
        } else if (m is String) {
          assignedMunicipalitiesList.add(MunicipalityEntity(id: m));
        }
      }
    }

    // STATUS ENUM
    VehicleStatus? status;
    final statusVal = json['status']?.toString();
    if (statusVal != null) {
      status = VehicleStatus.values.firstWhere(
        (s) => s.name == statusVal,
        orElse: () => VehicleStatus.goodCondition,
      );
    }

    return VehicleProfileModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),

      // Expanded entities
      deliveryVehicleData: deliveryVehicle,
      assignedTrips: assignedTripsList,
      driver: driver,
      createdBy: createdBy,
      designatedProvince: json['designatedProvince']?.toString(),
      designatedMunicipality: json['designatedMunicipality']?.toString(),
      designatedRegion: json['designatedRegion']?.toString(),
      remarks: json['remarks']?.toString(),
      yearModel: json['yearModel']?.toString(),

      // Assigned place lookups (multiple relations)
      assignedRegions: assignedRegionsList,
      assignedProvinces: assignedProvincesList,
      assignedMunicipalities: assignedMunicipalitiesList,

      // Relationship IDs
      deliveryVehicleId: json['deliveryVehicleData']?.toString(),
      assignedTripIds:
          json['assignedTrips'] != null
              ? List<String>.from(json['assignedTrips'])
              : [],
      assignedRegionIds:
          json['assignedRegion'] != null
              ? List<String>.from(json['assignedRegion'])
              : [],
      assignedProvinceIds:
          json['assignedProvince'] != null
              ? List<String>.from(json['assignedProvince'])
              : [],
      assignedMunicipalityIds:
          json['assignedMunicipality'] != null
              ? List<String>.from(json['assignedMunicipality'])
              : [],

      // Attachments
      attachmentFiles:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : [],

      status: status,
      created: json['created'] != null ? _parseDateTime(json['created']) : null,
      updated: json['updated'] != null ? _parseDateTime(json['updated']) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // TO JSON
  // ---------------------------------------------------------------------------
  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'deliveryVehicleData': deliveryVehicleId,
      'assignedTrips': assignedTripIds ?? [],
      'assignedRegion': assignedRegionIds ?? [],
      'assignedProvince': assignedProvinceIds ?? [],
      'assignedMunicipality': assignedMunicipalityIds ?? [],
      'attachments': attachmentFiles ?? [],
      'status': status?.name,
      'yearModel': yearModel,
      'remarks': remarks,
      'designatedProvince': designatedProvince,
      'designatedMunicipality': designatedMunicipality,
      'driver': driver,
      'createdBy': createdBy,
      'designatedRegion': designatedRegion,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // COPY WITH
  // ---------------------------------------------------------------------------
  VehicleProfileModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    DeliveryVehicleModel? deliveryVehicleData,
    List<TripModel>? assignedTrips,
    String? deliveryVehicleId,
    List<String>? assignedTripIds,
    GeneralUserModel? createdBy,
    PersonelModel? driver,
    String? designatedProvince,
    String? designatedMunicipality,
    String? designatedRegion,
    String? remarks,
    String? yearModel,
    VehicleStatus? status,
    List<String>? attachments,
    List<String>? attachmentFiles,
    List<RegionEntity>? assignedRegions,
    List<ProvinceEntity>? assignedProvinces,
    List<MunicipalityEntity>? assignedMunicipalities,
    List<String>? assignedRegionIds,
    List<String>? assignedProvinceIds,
    List<String>? assignedMunicipalityIds,
    DateTime? created,
    DateTime? updated,
  }) {
    return VehicleProfileModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      deliveryVehicleData: deliveryVehicleData ?? this.deliveryVehicleData,
      assignedTrips: assignedTrips ?? this.assignedTrips,
      deliveryVehicleId: deliveryVehicleId ?? this.deliveryVehicleId,
      assignedTripIds: assignedTripIds ?? this.assignedTripIds,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      attachmentFiles: attachmentFiles ?? this.attachmentFiles,
      designatedRegion: designatedRegion ?? this.designatedRegion,
      remarks: remarks ?? this.remarks,
      yearModel: yearModel ?? this.yearModel,
      driver: driver ?? this.driver,
      createdBy: createdBy ?? this.createdBy,
      designatedProvince: designatedProvince ?? this.designatedProvince,
      designatedMunicipality:
          designatedMunicipality ?? this.designatedMunicipality,
      assignedRegions: assignedRegions ?? this.assignedRegions,
      assignedProvinces: assignedProvinces ?? this.assignedProvinces,
      assignedMunicipalities:
          assignedMunicipalities ?? this.assignedMunicipalities,
      assignedRegionIds: assignedRegionIds ?? this.assignedRegionIds,
      assignedProvinceIds: assignedProvinceIds ?? this.assignedProvinceIds,
      assignedMunicipalityIds:
          assignedMunicipalityIds ?? this.assignedMunicipalityIds,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // ---------------------------------------------------------------------------
  // FROM ENTITY
  // ---------------------------------------------------------------------------
  factory VehicleProfileModel.fromEntity(VehicleProfileEntity entity) {
    return VehicleProfileModel(
      id: entity.id,
      collectionId: entity.collectionId,
      collectionName: entity.collectionName,
      deliveryVehicleData: entity.deliveryVehicleData,
      assignedTrips: entity.assignedTrips?.cast<TripModel>(),
      deliveryVehicleId: entity.deliveryVehicleData?.id,
      assignedTripIds:
          entity.assignedTrips?.map((t) => t.id ?? '').toList() ?? [],
      attachments: entity.attachments,
      attachmentFiles: entity.attachments?.cast<String>(),
      remarks: entity.remarks,
      yearModel: entity.yearModel,
      driver: entity.driver,
      createdBy: entity.createdBy,
      designatedProvince: entity.designatedProvince,
      designatedMunicipality: entity.designatedMunicipality,
      designatedRegion: entity.designatedRegion,
      assignedRegions: entity.assignedRegions?.cast<RegionEntity>(),
      assignedProvinces: entity.assignedProvinces?.cast<ProvinceEntity>(),
      assignedMunicipalities:
          entity.assignedMunicipalities?.cast<MunicipalityEntity>(),
      assignedRegionIds:
          entity.assignedRegions?.map((e) => e.id ?? '').toList() ?? [],
      assignedProvinceIds:
          entity.assignedProvinces?.map((e) => e.id ?? '').toList() ?? [],
      assignedMunicipalityIds:
          entity.assignedMunicipalities?.map((e) => e.id ?? '').toList() ?? [],
      status: entity.status,
      created: entity.created,
      updated: entity.updated,
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY MODEL
  // ---------------------------------------------------------------------------
  factory VehicleProfileModel.empty() {
    return VehicleProfileModel(
      id: '',
      collectionId: '',
      collectionName: '',
      deliveryVehicleData: null,
      assignedTrips: [],
      deliveryVehicleId: '',
      assignedTripIds: [],
      attachmentFiles: [],
      status: VehicleStatus.goodCondition,
      attachments: [],
      designatedProvince: null,
      designatedMunicipality: null,
      remarks: null,
      designatedRegion: null,
      yearModel: null,
      driver: null,
      createdBy: null,
      assignedRegions: [],
      assignedProvinces: [],
      assignedMunicipalities: [],
      assignedRegionIds: [],
      assignedProvinceIds: [],
      assignedMunicipalityIds: [],
      created: null,
      updated: null,
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER - SAFE DATE PARSE
  // ---------------------------------------------------------------------------
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      if (value is int) {
        return value > 9999999999
            ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal()
            : DateTime.fromMillisecondsSinceEpoch(
              value * 1000,
              isUtc: true,
            ).toLocal();
      }
      final strValue = value.toString().trim();
      try {
        final parsed = DateTime.parse(strValue);
        return parsed.isUtc ? parsed.toLocal() : parsed;
      } catch (_) {}
      return DateTime.tryParse(strValue);
    } catch (e) {
      debugPrint('❌ _parseDateTime error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // EQUALITY
  // ---------------------------------------------------------------------------
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
