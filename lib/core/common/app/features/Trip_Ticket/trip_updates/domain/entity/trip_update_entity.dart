import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/enums/trip_update_status.dart';
import 'package:equatable/equatable.dart';


class TripUpdateEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  TripUpdateStatus? status;
  DateTime? date;
  String? image;
  String? description;
  String? latitude;
  String? longitude;
  final TripModel? trip;

  TripUpdateEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.status,
    this.date,
    this.image,
    this.description,
    this.latitude,
    this.longitude,
    this.trip,
  });

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        status,
        date,
        image,
        description,
        latitude,
        longitude,
        trip?.id,
      ];
}
