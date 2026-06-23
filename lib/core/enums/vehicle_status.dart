/// All enums used by the Vehicle Data / Vehicle Profile forms.
///
/// The `.name` of each value is the stable identifier persisted in
/// PocketBase (e.g. "goodCondition"). The human-readable [label] is
/// the user-facing text shown in the dropdowns AND the value that is
/// written to the form's `TextEditingController` so that what the
/// user sees is what gets stored.
library;

enum VehicleStatus {
  goodCondition,
  underMaintenance,
  inspectionRequired,
  outOfService,
  retired,
}

enum VehicleType {
  truck,
  van,
  canter,
  truckElf,
  l300,
  l6wFwd,
  other;

  /// User-facing label (mixed case in the UI), suitable for the
  /// `type` field on `DeliveryVehicleModel`.
  String get label {
    switch (this) {
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.canter:
        return 'Canter';
      case VehicleType.truckElf:
        return 'Truck Elf';
      case VehicleType.l300:
        return 'L300';
      case VehicleType.l6wFwd:
        return '6W FWD';
      case VehicleType.other:
        return 'Other';
    }
  }
}

enum Make {
  mitsubishi,
  isuzu,
  hino,
  toyota,
  other;

  /// User-facing label (mixed case in the UI), suitable for the
  /// `make` field on `DeliveryVehicleModel`.
  String get label {
    switch (this) {
      case Make.mitsubishi:
        return 'Mitsubishi';
      case Make.isuzu:
        return 'Isuzu';
      case Make.hino:
        return 'Hino';
      case Make.toyota:
        return 'Toyota';
      case Make.other:
        return 'Other';
    }
  }
}
