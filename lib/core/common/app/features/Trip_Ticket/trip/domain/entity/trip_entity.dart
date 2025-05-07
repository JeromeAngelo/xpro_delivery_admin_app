import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/models/personel_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/data/model/vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/data/models/completed_customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/data/model/trip_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/data/model/undeliverable_customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/data/model/checklist_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/data/model/end_trip_checklist_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/data/model/end_trip_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/data/models/otp_models.dart';
import 'package:equatable/equatable.dart';


class TripEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  String? tripNumberId;
  final List<CustomerModel> customers;
  final DeliveryTeamModel? deliveryTeam;
  final List<PersonelModel> personels;
  final List<ChecklistModel> checklist;
  final List<VehicleModel> vehicle;
  final List<CompletedCustomerModel> completedCustomers;
  final List<ReturnModel> returns;
  final List<UndeliverableCustomerModel> undeliverableCustomers;
  final List<TransactionModel> transactions;
  final List<EndTripChecklistModel> endTripChecklist;
  final List<TripUpdateModel> tripUpdates;
  
  final OtpModel? otp;
  final EndTripOtpModel? endTripOtp;
  final GeneralUserModel? user;
  final List<InvoiceModel> invoices;
  double? latitude;  // Added latitude field
  double? longitude; // Added longitude field
  String? totalTripDistance;
  bool? isAccepted;
  bool? isEndTrip;
  DateTime? timeEndTrip;
  DateTime? timeAccepted;
  DateTime? created;
  DateTime? updated;
  String? qrCode;

  TripEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.tripNumberId,
    List<CustomerModel>? customers,
    this.deliveryTeam,
    List<PersonelModel>? personels,
    List<ChecklistModel>? checklist,
    List<TripUpdateModel>? tripUpdates,
    List<VehicleModel>? vehicle,
    List<CompletedCustomerModel>? completedCustomers,
    List<ReturnModel>? returns,
    List<UndeliverableCustomerModel>? undeliverableCustomers,
    List<TransactionModel>? transactions,
    List<EndTripChecklistModel>? endTripChecklist,
    this.otp,
    List<InvoiceModel>? invoices,
    this.endTripOtp,
    this.user,
    this.totalTripDistance,
    this.timeEndTrip,
    this.isEndTrip,
    this.timeAccepted,
    this.isAccepted,
    this.qrCode,
    this.created,
    this.updated,
    this.latitude,  // Added to constructor
    this.longitude, // Added to constructor
  }) : 
    customers = customers ?? [],
    personels = personels ?? [],
    checklist = checklist ?? [],
    vehicle = vehicle ?? [],
    completedCustomers = completedCustomers ?? [],
    returns = returns ?? [],
    undeliverableCustomers = undeliverableCustomers ?? [],
    transactions = transactions ?? [],
    endTripChecklist = endTripChecklist ?? [],
    tripUpdates = tripUpdates ?? [],
    invoices = invoices ?? [];

  @override
  List<Object?> get props => [
        id,
        tripNumberId,
        customers,
        deliveryTeam?.id,
        user?.id,
        totalTripDistance,
        invoices,
        personels,
        vehicle,
        checklist,
        completedCustomers,
        returns,
        undeliverableCustomers,
        transactions,
        endTripChecklist,
        tripUpdates,
        timeAccepted,
        otp?.id,
        endTripOtp?.id,
        timeEndTrip,
        isEndTrip,
        qrCode,
        isAccepted,
        created,
        updated,
        latitude,  // Added to props
        longitude, // Added to props
      ];
}
