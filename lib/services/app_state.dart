import "dart:async";
import "dart:math";
import "package:flutter/foundation.dart";
import "../models/user_model.dart";
import "../models/locker_model.dart";
import "../models/telemetry_model.dart";
import "database_helper.dart";

class AppState extends ChangeNotifier {
  UserModel _currentUser = UserModel.guest();
  UserModel get currentUser => _currentUser;
  bool get isMember => _currentUser.isMember;

  // Locations
  List<LockerLocation> _locations = [
    const LockerLocation(
      id: 'loc_kintamani',
      name: 'TEMPBOX Glamping Hub',
      category: 'Camping & Glamping',
      address: 'Jl. Raya Kintamani No. 88, Batur, Bali',
      distanceKm: 1.2,
      availableHot: 4,
      availableCold: 5,
      latitude: -8.2523,
      longitude: 115.3562,
    ),
    const LockerLocation(
      id: 'loc_lembang',
      name: 'TEMPBOX Ecotourism Sanctuary',
      category: 'Wisata Alam & Outdoor',
      address: 'Kawasan Wisata Tangkuban Perahu, Lembang, Bandung',
      distanceKm: 3.5,
      availableHot: 3,
      availableCold: 4,
      latitude: -6.7596,
      longitude: 107.6098,
    ),
    const LockerLocation(
      id: 'loc_grand_indonesia',
      name: 'TEMPBOX Central Mall Hub',
      category: 'Shopping Mall',
      address: 'Grand Indonesia West Mall LG Floor, Jakarta Pusat',
      distanceKm: 4.8,
      availableHot: 5,
      availableCold: 6,
      latitude: -6.1951,
      longitude: 106.8219,
    ),
    const LockerLocation(
      id: 'loc_siloam',
      name: 'TEMPBOX Care Hub (Medical & Fresh)',
      category: 'Fasilitas Publik',
      address: 'Lobby Tower B, Siloam Hospitals, Lippo Village',
      distanceKm: 6.2,
      availableHot: 2,
      availableCold: 5,
      latitude: -6.2255,
      longitude: 106.6083,
    ),
  ];
  List<LockerLocation> get locations => List.unmodifiable(_locations);

  // Selected Booking details
  LockerLocation? selectedLocation;
  StorageType selectedStorageType = StorageType.cold;
  Compartment? selectedCompartment;
  int selectedDurationHours = 3;

  // Active & Past Reservations
  Reservation? _activeReservation;
  Reservation? get activeReservation => _activeReservation;

  List<Reservation> _history = [];
  List<Reservation> get history => List.unmodifiable(_history);

  // IoT Telemetry Simulation
  LockerTelemetry? _liveTelemetry;
  LockerTelemetry? get liveTelemetry => _liveTelemetry;
  Timer? _telemetryTimer;

  AppState() {
    _initFromDatabase();
    _startTelemetryStream();
  }

  Future<void> _initFromDatabase() async {
    try {
      final savedUser = await DatabaseHelper.instance.getLatestUser();
      if (savedUser != null) {
        _currentUser = savedUser;
      }

      final active = await DatabaseHelper.instance.getActiveReservation(_locations);
      if (active != null) {
        _activeReservation = active;
        _updateTelemetryForReservation(active);
      }

      _history = await DatabaseHelper.instance.getReservationHistory(_locations);
      notifyListeners();
    } catch (e) {
      debugPrint('Database init error: $e');
    }
  }

  // --- Auth / Membership actions ---
  void continueAsGuest() {
    _currentUser = UserModel.guest();
    DatabaseHelper.instance.saveUser(_currentUser);
    notifyListeners();
  }

  void loginAsMember({
    required String name,
    required String email,
    required String phone,
    int initialSpending = 0,
    int points = 250,
  }) {
    _currentUser = UserModel.member(
      name: name.isEmpty ? 'Member TEMPBOX' : name,
      email: email.isEmpty ? 'member@tempbox.id' : email,
      phone: phone.isEmpty ? '081234567890' : phone,
      points: points,
      initialSpending: initialSpending,
    );
    DatabaseHelper.instance.saveUser(_currentUser);
    notifyListeners();
  }

  void logout() {
    _currentUser = UserModel.guest();
    DatabaseHelper.instance.saveUser(_currentUser);
    notifyListeners();
  }

  // --- Pricing Calculation ---
  int getHourlyRate(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 6 && hour < 18) {
      return 25000;
    } else {
      return 35000;
    }
  }

  Map<String, int> calculatePricing({
    required int hours,
    required DateTime startTime,
    bool applyMemberDiscount = false,
    int pointsToUse = 0,
  }) {
    final rate = getHourlyRate(startTime);
    final subtotal = rate * hours;
    final discount = (isMember && applyMemberDiscount) ? (subtotal * 0.1).round() : 0;
    
    // 1 poin = Rp 1 (e.g. 23 poin = Rp 23)
    final maxPointsAllowed = isMember ? _currentUser.loyaltyPoints : 0;
    final maxDeductible = (subtotal - discount).clamp(0, maxPointsAllowed);
    final actualPointsUsed = pointsToUse.clamp(0, maxDeductible);
    final pointsDiscount = actualPointsUsed; // 1 poin = Rp 1

    final total = subtotal - discount - pointsDiscount;
    // Points earned with tier multiplier:
    // 0-1jt: Silver (1x)
    // 1jt-5jt: Gold (2x)
    // 5jt-10jt: Diamond (3x)
    // 10jt+: Platinum (4x)
    final basePoints = (total ~/ 1000);
    final pointsEarned = isMember ? (basePoints * _currentUser.pointMultiplier) : 0;

    return {
      'hourlyRate': rate,
      'subtotal': subtotal,
      'discount': discount,
      'pointsUsed': actualPointsUsed,
      'pointsDiscount': pointsDiscount,
      'total': total,
      'pointsEarned': pointsEarned,
      'pointMultiplier': _currentUser.pointMultiplier,
    };
  }

  List<Compartment> getCompartmentsForSelection() {
    final loc = selectedLocation ?? _locations[0];
    final prefix = selectedStorageType == StorageType.hot ? 'H' : 'C';
    final targetTemp = selectedStorageType.defaultTargetTemp;
    final int availableCount = selectedStorageType == StorageType.hot
        ? loc.availableHot
        : loc.availableCold;

    return List.generate(6, (index) {
      final num = index + 1;
      // Exactly availableCount compartments are available (index < availableCount)
      final isAvailable = index < availableCount;
      final tempVariation = (selectedStorageType == StorageType.hot)
          ? 59.5 + (index * 0.3)
          : 3.8 + (index * 0.2);

      return Compartment(
        id: '$prefix-0$num',
        number: num,
        type: selectedStorageType,
        isAvailable: isAvailable,
        currentTemp: tempVariation,
        targetTemp: targetTemp,
      );
    });
  }

  // --- Create & Store Reservation in Database ---
  Reservation createReservation({
    required String paymentMethod,
    bool usePoints = false,
    int pointsToUse = 0,
  }) {
    final loc = selectedLocation ?? _locations[0];
    final type = selectedStorageType;
    final comp = selectedCompartment ??
        Compartment(
          id: type == StorageType.hot ? 'H-03' : 'C-02',
          number: 3,
          type: type,
          isAvailable: true,
          currentTemp: type.defaultTargetTemp,
          targetTemp: type.defaultTargetTemp,
        );

    final now = DateTime.now();
    final pricing = calculatePricing(
      hours: selectedDurationHours,
      startTime: now,
      applyMemberDiscount: true,
      pointsToUse: usePoints ? pointsToUse : 0,
    );

    final code = 'TBX-${Random().nextInt(899999) + 100000}';
    final pin = '${Random().nextInt(8999) + 1000}';
    final qrData = 'https://tempbox.id/access?code=$code&comp=${comp.id}&key=SEC_${Random().nextInt(99999)}';

    final reservation = Reservation(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      reservationCode: code,
      location: loc,
      compartment: comp,
      storageType: type,
      durationHours: selectedDurationHours,
      startTime: now,
      endTime: now.add(Duration(hours: selectedDurationHours)),
      hourlyRate: pricing['hourlyRate']!,
      subtotal: pricing['subtotal']!,
      discount: pricing['discount']!,
      totalAmount: pricing['total']!,
      pointsEarned: pricing['pointsEarned']!,
      pointsUsed: pricing['pointsUsed']!,
      paymentMethod: paymentMethod,
      qrCodeData: qrData,
      pinCode: pin,
      status: ReservationStatus.active,
      isDoorOpen: false,
    );

    // Decrement availability count for this location
    final locIndex = _locations.indexWhere((l) => l.id == loc.id);
    if (locIndex != -1) {
      final currentLoc = _locations[locIndex];
      _locations[locIndex] = currentLoc.copyWith(
        availableHot: type == StorageType.hot
            ? (currentLoc.availableHot - 1).clamp(0, 6)
            : currentLoc.availableHot,
        availableCold: type == StorageType.cold
            ? (currentLoc.availableCold - 1).clamp(0, 6)
            : currentLoc.availableCold,
      );
      selectedLocation = _locations[locIndex];
    }

    _activeReservation = reservation;

    // Update user spending and loyalty points in account
    if (isMember) {
      final updatedSpending = _currentUser.totalSpending + pricing['total']!;
      final updatedPoints = (_currentUser.loyaltyPoints - pricing['pointsUsed']! + pricing['pointsEarned']!).clamp(0, 999999);
      _currentUser = _currentUser.copyWith(
        totalSpending: updatedSpending,
        loyaltyPoints: updatedPoints,
      );
      DatabaseHelper.instance.saveUser(_currentUser);
    }

    // Persist reservation in SQLite database
    DatabaseHelper.instance.insertReservation(reservation);

    _updateTelemetryForReservation(reservation);
    notifyListeners();
    return reservation;
  }

  // --- Extend Active Reservation (Perpanjang Sewa) ---
  Future<void> extendActiveReservation({
    required int additionalHours,
    required String paymentMethod,
    bool usePoints = false,
    int pointsToUse = 0,
  }) async {
    if (_activeReservation == null) return;
    final now = DateTime.now();
    final pricing = calculatePricing(
      hours: additionalHours,
      startTime: now,
      applyMemberDiscount: true,
      pointsToUse: usePoints ? pointsToUse : 0,
    );

    final currentRes = _activeReservation!;
    final newEndTime = currentRes.endTime.add(Duration(hours: additionalHours));
    final newDuration = currentRes.durationHours + additionalHours;
    final newTotal = currentRes.totalAmount + pricing['total']!;
    final newPointsEarned = currentRes.pointsEarned + pricing['pointsEarned']!;
    final newPointsUsed = currentRes.pointsUsed + pricing['pointsUsed']!;

    _activeReservation = Reservation(
      id: currentRes.id,
      reservationCode: currentRes.reservationCode,
      location: currentRes.location,
      compartment: currentRes.compartment,
      storageType: currentRes.storageType,
      durationHours: newDuration,
      startTime: currentRes.startTime,
      endTime: newEndTime,
      hourlyRate: currentRes.hourlyRate,
      subtotal: currentRes.subtotal + pricing['subtotal']!,
      discount: currentRes.discount + pricing['discount']!,
      totalAmount: newTotal,
      pointsEarned: newPointsEarned,
      pointsUsed: newPointsUsed,
      paymentMethod: paymentMethod,
      qrCodeData: currentRes.qrCodeData,
      pinCode: currentRes.pinCode,
      status: currentRes.status,
      isDoorOpen: currentRes.isDoorOpen,
    );

    if (isMember) {
      final updatedSpending = _currentUser.totalSpending + pricing['total']!;
      final updatedPoints = (_currentUser.loyaltyPoints - pricing['pointsUsed']! + pricing['pointsEarned']!).clamp(0, 999999);
      _currentUser = _currentUser.copyWith(
        totalSpending: updatedSpending,
        loyaltyPoints: updatedPoints,
      );
      await DatabaseHelper.instance.saveUser(_currentUser);
    }

    await DatabaseHelper.instance.extendReservation(
      id: currentRes.id,
      newEndTime: newEndTime,
      addedHours: additionalHours,
      addedAmount: pricing['total']!,
      addedPoints: pricing['pointsEarned']!,
    );

    notifyListeners();
  }

  // --- Locker Door interaction ---
  void toggleDoor(bool open) {
    if (_activeReservation != null) {
      _activeReservation = _activeReservation!.copyWith(isDoorOpen: open);
      if (_liveTelemetry != null) {
        _liveTelemetry = LockerTelemetry(
          compartmentId: _liveTelemetry!.compartmentId,
          temperature: _liveTelemetry!.temperature + (open ? 1.2 : 0.0),
          targetTemperature: _liveTelemetry!.targetTemperature,
          humidity: _liveTelemetry!.humidity,
          isDoorLocked: !open,
          powerSource: _liveTelemetry!.powerSource,
          batteryLevel: _liveTelemetry!.batteryLevel,
          powerConsumptionWatts: open ? 65.0 : 42.0,
          networkStatus: _liveTelemetry!.networkStatus,
          lastUpdated: DateTime.now(),
        );
      }
      notifyListeners();
    }
  }

  // --- Complete Retrieval & Update Database ---
  void completeRetrieval({required double rating, String? feedback}) {
    if (_activeReservation != null) {
      final reservationId = _activeReservation!.id;
      final completed = _activeReservation!.copyWith(
        status: ReservationStatus.completed,
        isDoorOpen: false,
      );
      _history.insert(0, completed);
      _activeReservation = null;
      _liveTelemetry = null;

      // Increment availability count back for this location
      final locIndex = _locations.indexWhere((l) => l.id == _activeReservation!.location.id);
      if (locIndex != -1) {
        final currentLoc = _locations[locIndex];
        final type = _activeReservation!.storageType;
        _locations[locIndex] = currentLoc.copyWith(
          availableHot: type == StorageType.hot
              ? (currentLoc.availableHot + 1).clamp(0, 6)
              : currentLoc.availableHot,
          availableCold: type == StorageType.cold
              ? (currentLoc.availableCold + 1).clamp(0, 6)
              : currentLoc.availableCold,
        );
      }

      // Update SQLite Database
      DatabaseHelper.instance.updateReservationCompleted(
        id: reservationId,
        rating: rating,
        feedback: feedback,
      );

      notifyListeners();
    }
  }

  void _updateTelemetryForReservation(Reservation res) {
    final target = res.storageType.defaultTargetTemp;
    _liveTelemetry = LockerTelemetry(
      compartmentId: res.compartment.id,
      temperature: target + (Random().nextDouble() * 0.4 - 0.2),
      targetTemperature: target,
      humidity: res.storageType == StorageType.hot ? 35.0 : 62.0,
      isDoorLocked: true,
      powerSource: 'Solar Hybrid',
      batteryLevel: 98,
      powerConsumptionWatts: 42.5,
      networkStatus: 'Online',
      lastUpdated: DateTime.now(),
    );
  }

  void _startTelemetryStream() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_activeReservation != null && _liveTelemetry != null) {
        final randDelta = (Random().nextDouble() * 0.3) - 0.15;
        final newTemp = (_liveTelemetry!.temperature + randDelta)
            .clamp(
              _liveTelemetry!.targetTemperature - 1.5,
              _liveTelemetry!.targetTemperature + 1.5,
            );

        _liveTelemetry = LockerTelemetry(
          compartmentId: _liveTelemetry!.compartmentId,
          temperature: double.parse(newTemp.toStringAsFixed(1)),
          targetTemperature: _liveTelemetry!.targetTemperature,
          humidity: _liveTelemetry!.humidity,
          isDoorLocked: !_activeReservation!.isDoorOpen,
          powerSource: _liveTelemetry!.powerSource,
          batteryLevel: _liveTelemetry!.batteryLevel,
          powerConsumptionWatts: _liveTelemetry!.powerConsumptionWatts,
          networkStatus: 'Online',
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
