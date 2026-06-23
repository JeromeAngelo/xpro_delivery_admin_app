/// Place-lookup enums used by the Vehicle Profile form.
///
/// Two enums are provided:
///
///   * [DesignatedRegion] – the 17 regions of the Philippines (only
///     the four most commonly used by the delivery fleet are defined
///     here; extend the list as needed).
///   * [DesignatedProvince] – the full list of provinces across the
///     four supported regions.
///
/// The enums are also Dart `enum` values, so callers can use
/// `DesignatedRegion.regionIII.name` for a stable string identifier
/// in the database. The human-readable label is exposed via the
/// [label] extension getter; the optional [regionOf] getter on
/// [DesignatedProvince] lets the UI group provinces under their
/// region in dropdowns.
///
/// Storage format: the form currently stores these fields as plain
/// `String` values (see `VehicleProfileEntity.designatedRegion` /
/// `.designatedProvince`). Use [label] when serialising to
/// PocketBase so the stored value matches what the user sees on
/// screen.
library;

/// The supported regions of the Philippines for the vehicle profile.
///
/// Only the regions used by the delivery fleet are enumerated. Add
/// more entries as needed; the UI will surface them automatically.
enum DesignatedRegion {
  regionI,
  regionII,
  cordilleraAdministrativeRegion,
  regionIII;

  /// Human-readable label, suitable for both the UI and the
  /// PocketBase "designatedRegion" field. Format: "Region I – Ilocos
  /// Region" / "Cordillera Administrative Region" etc.
  String get label {
    switch (this) {
      case DesignatedRegion.regionI:
        return 'Region I – Ilocos Region';
      case DesignatedRegion.regionII:
        return 'Region II – Cagayan Valley';
      case DesignatedRegion.cordilleraAdministrativeRegion:
        return 'Cordillera Administrative Region';
      case DesignatedRegion.regionIII:
        return 'Region III – Central Luzon';
    }
  }

  /// Provinces that belong to this region. Used by dropdowns to
  /// filter the province list when a region is selected.
  List<DesignatedProvince> get provinces {
    return DesignatedProvince.values
        .where((p) => p.regionOf == this)
        .toList(growable: false);
  }
}

/// The supported provinces of the Philippines for the vehicle
/// profile, grouped by [DesignatedRegion].
enum DesignatedProvince {
  // Region I – Ilocos Region
  ilocosNorte(DesignatedRegion.regionI),
  ilocosSur(DesignatedRegion.regionI),
  laUnion(DesignatedRegion.regionI),
  pangasinan(DesignatedRegion.regionI),

  // Region II – Cagayan Valley
  batanes(DesignatedRegion.regionII),
  cagayan(DesignatedRegion.regionII),
  isabela(DesignatedRegion.regionII),
  nuevaVizcaya(DesignatedRegion.regionII),
  quirino(DesignatedRegion.regionII),

  // Cordillera Administrative Region (CAR)
  abra(DesignatedRegion.cordilleraAdministrativeRegion),
  apayao(DesignatedRegion.cordilleraAdministrativeRegion),
  benguet(DesignatedRegion.cordilleraAdministrativeRegion),
  ifugao(DesignatedRegion.cordilleraAdministrativeRegion),
  kalinga(DesignatedRegion.cordilleraAdministrativeRegion),
  mountainProvince(DesignatedRegion.cordilleraAdministrativeRegion),

  // Region III – Central Luzon
  aurora(DesignatedRegion.regionIII),
  bataan(DesignatedRegion.regionIII),
  bulacan(DesignatedRegion.regionIII),
  nuevaEcija(DesignatedRegion.regionIII),
  pampanga(DesignatedRegion.regionIII),
  tarlac(DesignatedRegion.regionIII),
  zambales(DesignatedRegion.regionIII);

  const DesignatedProvince(this.regionOf);

  /// The region this province belongs to.
  final DesignatedRegion regionOf;

  /// Human-readable label, suitable for both the UI and the
  /// PocketBase "designatedProvince" field. The label uses the
  /// proper title-case, multi-word format (e.g. "Mountain Province"
  /// rather than "mountainProvince").
  String get label {
    switch (this) {
      // Region I
      case DesignatedProvince.ilocosNorte:
        return 'Ilocos Norte';
      case DesignatedProvince.ilocosSur:
        return 'Ilocos Sur';
      case DesignatedProvince.laUnion:
        return 'La Union';
      case DesignatedProvince.pangasinan:
        return 'Pangasinan';

      // Region II
      case DesignatedProvince.batanes:
        return 'Batanes';
      case DesignatedProvince.cagayan:
        return 'Cagayan';
      case DesignatedProvince.isabela:
        return 'Isabela';
      case DesignatedProvince.nuevaVizcaya:
        return 'Nueva Vizcaya';
      case DesignatedProvince.quirino:
        return 'Quirino';

      // CAR
      case DesignatedProvince.abra:
        return 'Abra';
      case DesignatedProvince.apayao:
        return 'Apayao';
      case DesignatedProvince.benguet:
        return 'Benguet';
      case DesignatedProvince.ifugao:
        return 'Ifugao';
      case DesignatedProvince.kalinga:
        return 'Kalinga';
      case DesignatedProvince.mountainProvince:
        return 'Mountain Province';

      // Region III
      case DesignatedProvince.aurora:
        return 'Aurora';
      case DesignatedProvince.bataan:
        return 'Bataan';
      case DesignatedProvince.bulacan:
        return 'Bulacan';
      case DesignatedProvince.nuevaEcija:
        return 'Nueva Ecija';
      case DesignatedProvince.pampanga:
        return 'Pampanga';
      case DesignatedProvince.tarlac:
        return 'Tarlac';
      case DesignatedProvince.zambales:
        return 'Zambales';
    }
  }
}

/// Try to parse a [DesignatedRegion] from the text the form saved
/// (i.e. the [DesignatedRegion.label]). Returns `null` when no
/// match is found – useful when reading existing records back from
/// PocketBase.
extension DesignatedRegionParsing on DesignatedRegion {
  static DesignatedRegion? fromLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    for (final region in DesignatedRegion.values) {
      if (region.label == trimmed) return region;
    }
    return null;
  }
}

/// Try to parse a [DesignatedProvince] from the text the form saved
/// (i.e. the [DesignatedProvince.label]). Returns `null` when no
/// match is found.
extension DesignatedProvinceParsing on DesignatedProvince {
  static DesignatedProvince? fromLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    for (final province in DesignatedProvince.values) {
      if (province.label == trimmed) return province;
    }
    return null;
  }
}
