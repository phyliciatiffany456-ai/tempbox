import "dart:async";
import "package:flutter/foundation.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../models/user_model.dart";
import "../models/locker_model.dart";

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB("tempbox.db");
      return _database!;
    } catch (e) {
      debugPrint("Database initialization fallback: $e");
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE users ADD COLUMN total_spending INTEGER NOT NULL DEFAULT 0");
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_member INTEGER NOT NULL,
        loyalty_points INTEGER NOT NULL,
        total_spending INTEGER NOT NULL DEFAULT 0,
        membership_tier TEXT NOT NULL,
        referral_code TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        reservation_code TEXT NOT NULL,
        location_id TEXT NOT NULL,
        location_name TEXT NOT NULL,
        location_address TEXT NOT NULL,
        compartment_id TEXT NOT NULL,
        storage_type TEXT NOT NULL,
        duration_hours INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        hourly_rate INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        discount INTEGER NOT NULL,
        points_used INTEGER NOT NULL DEFAULT 0,
        total_amount INTEGER NOT NULL,
        points_earned INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        qr_code_data TEXT NOT NULL,
        pin_code TEXT NOT NULL,
        status TEXT NOT NULL,
        rating REAL,
        feedback TEXT
      )
    ''');
  }

  Future<void> saveUser(UserModel user) async {
    try {
      final db = await instance.database;
      if (db == null) return;
      await db.insert(
        'users',
        {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'is_member': user.isMember ? 1 : 0,
          'loyalty_points': user.loyaltyPoints,
          'total_spending': user.totalSpending,
          'membership_tier': user.membershipTier,
          'referral_code': user.referralCode,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint("DB saveUser error: $e");
    }
  }

  Future<UserModel?> getLatestUser() async {
    try {
      final db = await instance.database;
      if (db == null) return null;
      final maps = await db.query(
        'users',
        orderBy: 'rowid DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final map = maps.first;
        return UserModel(
          id: map['id'] as String,
          name: map['name'] as String,
          email: map['email'] as String,
          phone: map['phone'] as String,
          isMember: (map['is_member'] as int) == 1,
          loyaltyPoints: map['loyalty_points'] as int,
          totalSpending: (map['total_spending'] as int?) ?? 0,
          referralCode: map['referral_code'] as String,
        );
      }
    } catch (e) {
      debugPrint("DB getLatestUser error: $e");
    }
    return null;
  }

  Future<void> insertReservation(Reservation res) async {
    try {
      final db = await instance.database;
      if (db == null) return;
      await db.insert(
        'reservations',
        {
          'id': res.id,
          'reservation_code': res.reservationCode,
          'location_id': res.location.id,
          'location_name': res.location.name,
          'location_address': res.location.address,
          'compartment_id': res.compartment.id,
          'storage_type': res.storageType == StorageType.hot ? 'hot' : 'cold',
          'duration_hours': res.durationHours,
          'start_time': res.startTime.toIso8601String(),
          'end_time': res.endTime.toIso8601String(),
          'hourly_rate': res.hourlyRate,
          'subtotal': res.subtotal,
          'discount': res.discount,
          'points_used': res.pointsUsed,
          'total_amount': res.totalAmount,
          'points_earned': res.pointsEarned,
          'payment_method': res.paymentMethod,
          'qr_code_data': res.qrCodeData,
          'pin_code': res.pinCode,
          'status': res.status == ReservationStatus.active ? 'active' : 'completed',
          'rating': 5.0,
          'feedback': '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint("DB insertReservation error: $e");
    }
  }

  Future<void> extendReservation({
    required String id,
    required DateTime newEndTime,
    required int addedHours,
    required int addedAmount,
    required int addedPoints,
  }) async {
    try {
      final db = await instance.database;
      if (db == null) return;
      final current = await db.query('reservations', where: 'id = ?', whereArgs: [id]);
      if (current.isNotEmpty) {
        final cur = current.first;
        final curHours = (cur['duration_hours'] as int?) ?? 0;
        final curTotal = (cur['total_amount'] as int?) ?? 0;
        final curPoints = (cur['points_earned'] as int?) ?? 0;

        await db.update(
          'reservations',
          {
            'end_time': newEndTime.toIso8601String(),
            'duration_hours': curHours + addedHours,
            'total_amount': curTotal + addedAmount,
            'points_earned': curPoints + addedPoints,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      debugPrint("DB extendReservation error: $e");
    }
  }

  Future<void> updateReservationCompleted({
    required String id,
    required double rating,
    String? feedback,
  }) async {
    try {
      final db = await instance.database;
      if (db == null) return;
      await db.update(
        'reservations',
        {
          'status': 'completed',
          'rating': rating,
          'feedback': feedback ?? '',
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint("DB updateReservationCompleted error: $e");
    }
  }

  Future<Reservation?> getActiveReservation(List<LockerLocation> locations) async {
    try {
      final db = await instance.database;
      if (db == null) return null;
      final maps = await db.query(
        'reservations',
        where: 'status = ?',
        whereArgs: ['active'],
        orderBy: 'start_time DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToReservation(maps.first, locations);
      }
    } catch (e) {
      debugPrint("DB getActiveReservation error: $e");
    }
    return null;
  }

  Future<List<Reservation>> getReservationHistory(List<LockerLocation> locations) async {
    try {
      final db = await instance.database;
      if (db == null) return [];
      final maps = await db.query(
        'reservations',
        where: 'status = ?',
        whereArgs: ['completed'],
        orderBy: 'start_time DESC',
      );

      return maps.map((m) => _mapToReservation(m, locations)).toList();
    } catch (e) {
      debugPrint("DB getReservationHistory error: $e");
    }
    return [];
  }

  Reservation _mapToReservation(Map<String, dynamic> map, List<LockerLocation> locations) {
    final locId = map['location_id'] as String;
    final loc = locations.firstWhere(
      (l) => l.id == locId,
      orElse: () => LockerLocation(
        id: locId,
        name: map['location_name'] as String,
        category: 'TEMPBOX Hub',
        address: map['location_address'] as String,
        distanceKm: 1.0,
        availableHot: 3,
        availableCold: 3,
      ),
    );

    final isHot = (map['storage_type'] as String) == 'hot';
    final type = isHot ? StorageType.hot : StorageType.cold;

    final compId = map['compartment_id'] as String;
    final comp = Compartment(
      id: compId,
      number: int.tryParse(compId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1,
      type: type,
      isAvailable: false,
      currentTemp: type.defaultTargetTemp,
      targetTemp: type.defaultTargetTemp,
    );

    return Reservation(
      id: map['id'] as String,
      reservationCode: map['reservation_code'] as String,
      location: loc,
      compartment: comp,
      storageType: type,
      durationHours: map['duration_hours'] as int,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      hourlyRate: map['hourly_rate'] as int,
      subtotal: map['subtotal'] as int,
      discount: map['discount'] as int,
      pointsUsed: (map['points_used'] as int?) ?? 0,
      totalAmount: map['total_amount'] as int,
      pointsEarned: map['points_earned'] as int,
      paymentMethod: map['payment_method'] as String,
      qrCodeData: map['qr_code_data'] as String,
      pinCode: map['pin_code'] as String,
      status: (map['status'] as String) == 'active'
          ? ReservationStatus.active
          : ReservationStatus.completed,
    );
  }
}
