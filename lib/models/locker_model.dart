enum StorageType {
  hot,
  cold,
}

extension StorageTypeExtension on StorageType {
  String get title => this == StorageType.hot ? 'Hot Storage' : 'Cold Storage';
  String get subtitle => this == StorageType.hot
      ? 'Makanan Hangat & Siap Saji (55°C - 65°C)'
      : 'Minuman, ASI, Obat-obatan & Makanan Segar (2°C - 6°C)';
  double get defaultTargetTemp => this == StorageType.hot ? 60.0 : 4.0;
  String get tempRange => this == StorageType.hot ? '55°C ~ 65°C' : '2°C ~ 6°C';
}

class LockerLocation {
  final String id;
  final String name;
  final String category;
  final String address;
  final double distanceKm;
  final int availableHot;
  final int availableCold;
  final String operationalHours;
  final double latitude;
  final double longitude;

  const LockerLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.distanceKm,
    required this.availableHot,
    required this.availableCold,
    this.operationalHours = '24 Jam (Non-stop)',
    this.latitude = -6.2000,
    this.longitude = 106.8166,
  });

  String get googleMapsUrl => 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  LockerLocation copyWith({
    int? availableHot,
    int? availableCold,
  }) {
    return LockerLocation(
      id: id,
      name: name,
      category: category,
      address: address,
      distanceKm: distanceKm,
      availableHot: availableHot ?? this.availableHot,
      availableCold: availableCold ?? this.availableCold,
      operationalHours: operationalHours,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class Compartment {
  final String id;
  final int number;
  final StorageType type;
  final bool isAvailable;
  final double currentTemp;
  final double targetTemp;

  const Compartment({
    required this.id,
    required this.number,
    required this.type,
    required this.isAvailable,
    required this.currentTemp,
    required this.targetTemp,
  });
}

enum ReservationStatus {
  active,
  completed,
  expired,
}

class Reservation {
  final String id;
  final String reservationCode;
  final LockerLocation location;
  final Compartment compartment;
  final StorageType storageType;
  final int durationHours;
  final DateTime startTime;
  final DateTime endTime;
  final int hourlyRate;
  final int subtotal;
  final int discount;
  final int totalAmount;
  final int pointsEarned;
  final int pointsUsed;
  final String paymentMethod;
  final String qrCodeData;
  final String pinCode;
  final ReservationStatus status;
  final bool isDoorOpen;

  const Reservation({
    required this.id,
    required this.reservationCode,
    required this.location,
    required this.compartment,
    required this.storageType,
    required this.durationHours,
    required this.startTime,
    required this.endTime,
    required this.hourlyRate,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.pointsEarned,
    this.pointsUsed = 0,
    required this.paymentMethod,
    required this.qrCodeData,
    required this.pinCode,
    this.status = ReservationStatus.active,
    this.isDoorOpen = false,
  });

  Reservation copyWith({
    ReservationStatus? status,
    bool? isDoorOpen,
  }) {
    return Reservation(
      id: id,
      reservationCode: reservationCode,
      location: location,
      compartment: compartment,
      storageType: storageType,
      durationHours: durationHours,
      startTime: startTime,
      endTime: endTime,
      hourlyRate: hourlyRate,
      subtotal: subtotal,
      discount: discount,
      totalAmount: totalAmount,
      pointsEarned: pointsEarned,
      pointsUsed: pointsUsed,
      paymentMethod: paymentMethod,
      qrCodeData: qrCodeData,
      pinCode: pinCode,
      status: status ?? this.status,
      isDoorOpen: isDoorOpen ?? this.isDoorOpen,
    );
  }
}
