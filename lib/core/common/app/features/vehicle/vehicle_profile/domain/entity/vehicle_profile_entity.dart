import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/delivery_team/personels/data/models/personel_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/municipality/domain/entity/municipality_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/domain/entity/province_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/domain/entity/region_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/data/models/trip_models.dart';

import '../../../../../../../enums/vehicle_status.dart';
import '../../../../general_auth/data/models/auth_models.dart'
    show GeneralUserModel;

class VehicleProfileEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  DeliveryVehicleModel? deliveryVehicleData;
  List<TripModel>? assignedTrips;

  /// New field for file attachments from PocketBase
  List<String>? attachments;
  String? designatedProvince;
  String? designatedMunicipality;
  DateTime? created;
  DateTime? updated;
  VehicleStatus? status;
  String? designatedRegion;
  String? remarks;
  String? yearModel;
  PersonelModel? driver;
  GeneralUserModel? createdBy;

  // ---------------------------------------------------------------------------
  // ASSIGNED PLACE LOOKUPS (multiple-relation fields on `vehicleProfile`)
  //   - assignedRegion      → List<RegionEntity>
  //   - assignedProvince    → List<ProvinceEntity>
  //   - assignedMunicipality → List<MunicipalityEntity>
  // ---------------------------------------------------------------------------
  List<RegionEntity>? assignedRegions;
  List<ProvinceEntity>? assignedProvinces;
  List<MunicipalityEntity>? assignedMunicipalities;

  VehicleProfileEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.deliveryVehicleData,
    this.assignedTrips,
    this.attachments,
    this.status,
    this.created,
    this.updated,
    this.remarks,
    this.designatedRegion,
    this.yearModel,
    this.driver,
    this.designatedProvince,
    this.designatedMunicipality,
    this.createdBy,
    this.assignedRegions,
    this.assignedProvinces,
    this.assignedMunicipalities,
  });

  factory VehicleProfileEntity.empty() {
    return VehicleProfileEntity(
      id: '',
      collectionId: '',
      collectionName: '',
      deliveryVehicleData: null,
      assignedTrips: [],
      attachments: [],
      status: VehicleStatus.goodCondition,
      created: null,
      updated: null,
      remarks: null,
      yearModel: null,
      driver: null,
      designatedRegion: null,
      designatedProvince: null,
      designatedMunicipality: null,
      createdBy: null,
      assignedRegions: [],
      assignedProvinces: [],
      assignedMunicipalities: [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    deliveryVehicleData?.id,
    assignedTrips?.map((trip) => trip.id).toList(),
    attachments,
    designatedProvince,
    designatedMunicipality,
    status,
    created,
    updated,
    remarks,
    designatedRegion,
    yearModel,
    driver,
    createdBy,
    assignedRegions?.map((e) => e.id).toList(),
    assignedProvinces?.map((e) => e.id).toList(),
    assignedMunicipalities?.map((e) => e.id).toList(),
  ];
}
