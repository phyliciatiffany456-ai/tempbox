class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isMember;
  final int loyaltyPoints;
  final int totalSpending; // Total belanja kumulatif dalam rupiah
  final String referralCode;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isMember,
    this.loyaltyPoints = 0,
    this.totalSpending = 0,
    this.referralCode = 'TEMPBOX2026',
  });

  // Dynamic Tier calculation based on total spending
  String get membershipTier {
    if (!isMember) return 'Mode Tamu';
    if (totalSpending >= 10000000) return 'Platinum Member';
    if (totalSpending >= 5000000) return 'Diamond Member';
    if (totalSpending >= 1000000) return 'Gold Member';
    return 'Silver Member';
  }

  // Point multiplier based on tier
  int get pointMultiplier {
    if (!isMember) return 0;
    if (totalSpending >= 10000000) return 4;
    if (totalSpending >= 5000000) return 3;
    if (totalSpending >= 1000000) return 2;
    return 1;
  }

  factory UserModel.guest() {
    return const UserModel(
      id: 'guest_user',
      name: 'Pengguna Tamu',
      email: 'guest@tempbox.id',
      phone: '-',
      isMember: false,
      loyaltyPoints: 0,
      totalSpending: 0,
      referralCode: '-',
    );
  }

  factory UserModel.member({
    required String name,
    required String email,
    required String phone,
    int points = 100,
    int initialSpending = 0,
  }) {
    return UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      isMember: true,
      loyaltyPoints: points,
      totalSpending: initialSpending,
      referralCode: 'TBX${phone.length > 4 ? phone.substring(phone.length - 4) : '2026'}',
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isMember,
    int? loyaltyPoints,
    int? totalSpending,
    String? referralCode,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isMember: isMember ?? this.isMember,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalSpending: totalSpending ?? this.totalSpending,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}
