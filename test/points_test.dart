import "package:flutter_test/flutter_test.dart";
import "package:tempbox_app/services/app_state.dart";

void main() {
  test("Points calculation: 1 pt = 1 Rp and 22.5k total gives 22 points", () {
    final appState = AppState();
    appState.loginAsMember(name: "Test User", email: "test@tempbox.id", phone: "0812345678");

    // 1 hour at 10:00 AM (Day rate = 25,000)
    // Subtotal = 25,000. Member discount 10% = 2,500.
    // Total without points = 22,500.
    final pricing1 = appState.calculatePricing(
      hours: 1,
      startTime: DateTime(2026, 9, 18, 10, 0),
      applyMemberDiscount: true,
      pointsToUse: 0,
    );

    expect(pricing1['subtotal'], 25000);
    expect(pricing1['discount'], 2500);
    expect(pricing1['total'], 22500);
    // User requirement: When total is 22.5k, the point they should get is 22!
    expect(pricing1['pointsEarned'], 22);

    // Using 23 points:
    // User requirement: 23 poin = 23 Rp!
    final pricing2 = appState.calculatePricing(
      hours: 1,
      startTime: DateTime(2026, 9, 18, 10, 0),
      applyMemberDiscount: true,
      pointsToUse: 23,
    );

    expect(pricing2['pointsUsed'], 23);
    expect(pricing2['pointsDiscount'], 23);
    expect(pricing2['total'], 22500 - 23); // 22477
    expect(pricing2['pointsEarned'], 22); // 22477 ~/ 1000 = 22!
  });

  test("Membership tiers and point multipliers based on spending", () {
    final appState = AppState();
    
    // Silver (0 - 1jt): 1x
    appState.loginAsMember(name: "Silver User", email: "silver@tempbox.id", phone: "0811111111", initialSpending: 500000);
    expect(appState.currentUser.membershipTier, 'Silver Member');
    expect(appState.currentUser.pointMultiplier, 1);
    var p = appState.calculatePricing(hours: 1, startTime: DateTime(2026, 9, 18, 10, 0), applyMemberDiscount: true);
    expect(p['pointsEarned'], 22); // 22 * 1 = 22

    // Gold (1jt - 5jt): 2x
    appState.loginAsMember(name: "Gold User", email: "gold@tempbox.id", phone: "0822222222", initialSpending: 2500000);
    expect(appState.currentUser.membershipTier, 'Gold Member');
    expect(appState.currentUser.pointMultiplier, 2);
    p = appState.calculatePricing(hours: 1, startTime: DateTime(2026, 9, 18, 10, 0), applyMemberDiscount: true);
    expect(p['pointsEarned'], 44); // 22 * 2 = 44

    // Diamond (5jt - 10jt): 3x
    appState.loginAsMember(name: "Diamond User", email: "diamond@tempbox.id", phone: "0833333333", initialSpending: 7000000);
    expect(appState.currentUser.membershipTier, 'Diamond Member');
    expect(appState.currentUser.pointMultiplier, 3);
    p = appState.calculatePricing(hours: 1, startTime: DateTime(2026, 9, 18, 10, 0), applyMemberDiscount: true);
    expect(p['pointsEarned'], 66); // 22 * 3 = 66

    // Platinum (10jt keatas): 4x
    appState.loginAsMember(name: "Platinum User", email: "plat@tempbox.id", phone: "0844444444", initialSpending: 12000000);
    expect(appState.currentUser.membershipTier, 'Platinum Member');
    expect(appState.currentUser.pointMultiplier, 4);
    p = appState.calculatePricing(hours: 1, startTime: DateTime(2026, 9, 18, 10, 0), applyMemberDiscount: true);
    expect(p['pointsEarned'], 88); // 22 * 4 = 88
  });
}
