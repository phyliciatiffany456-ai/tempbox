import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/locker_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ExtendRentalSheet extends StatefulWidget {
  final AppState appState;
  final Reservation reservation;

  const ExtendRentalSheet({
    super.key,
    required this.appState,
    required this.reservation,
  });

  static Future<void> show(BuildContext context, AppState appState, Reservation reservation) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExtendRentalSheet(appState: appState, reservation: reservation),
    );
  }

  @override
  State<ExtendRentalSheet> createState() => _ExtendRentalSheetState();
}

class _ExtendRentalSheetState extends State<ExtendRentalSheet> {
  int _additionalHours = 2;
  bool _usePoints = false;
  String _selectedPaymentMethod = 'QRIS';
  bool _isSubmitting = false;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _timeFormat = DateFormat('HH:mm, dd MMM');

  final List<String> _paymentMethods = ['QRIS', 'GoPay', 'BCA VA', 'Mandiri VA'];

  @override
  Widget build(BuildContext context) {
    final res = widget.reservation;
    final isHot = res.storageType == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;
    final user = widget.appState.currentUser;

    final pricing = widget.appState.calculatePricing(
      hours: _additionalHours,
      startTime: res.endTime,
      applyMemberDiscount: true,
      pointsToUse: _usePoints ? user.loyaltyPoints : 0,
    );

    final newEndTime = res.endTime.add(Duration(hours: _additionalHours));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.update_rounded, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perpanjang Sewa Loker',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Kompartemen  • ',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current vs Extended Time
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selesai Saat Ini', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          _timeFormat.format(res.endTime),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Selesai Baru', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          _timeFormat.format(newEndTime),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Additional Hours Selector
            const Text(
              'Tambah Durasi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [1, 2, 3, 4, 6, 8, 12, 24].map((h) {
                  final isSel = _additionalHours == h;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('+$h Jam'),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _additionalHours = h);
                      },
                      selectedColor: accentColor,
                      backgroundColor: AppColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      side: BorderSide(color: isSel ? accentColor : AppColors.border),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Custom hours stepper
            Row(
              children: [
                const Text('Atur Kustom:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                  onPressed: _additionalHours > 1
                      ? () => setState(() => _additionalHours--)
                      : null,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '$_additionalHours Jam',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  onPressed: () => setState(() => _additionalHours++),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Loyalty Points Option
            if (widget.appState.isMember && user.loyaltyPoints > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.brandYellow, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gunakan ${user.loyaltyPoints} Poin Loyalty (-${_currency.format(user.loyaltyPoints)})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                      ),
                    ),
                    Switch(
                      value: _usePoints,
                      activeColor: AppColors.brandYellow,
                      onChanged: (val) => setState(() => _usePoints = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Payment Method Quick Selection
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _paymentMethods.map((method) {
                  final isSel = _selectedPaymentMethod == method;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(method),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedPaymentMethod = method);
                      },
                      selectedColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Cost Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya Tambahan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(_currency.format(pricing['subtotal']), style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    ],
                  ),
                  if (widget.appState.isMember && (pricing['discount'] ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Diskon Member (10%)', style: TextStyle(fontSize: 12, color: AppColors.success)),
                        Text('- ${_currency.format(pricing["discount"])}', style: const TextStyle(fontSize: 12, color: AppColors.success)),
                      ],
                    ),
                  ],
                  if (_usePoints && (pricing['pointsDiscount'] ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Potongan Poin', style: TextStyle(fontSize: 12, color: AppColors.brandYellow)),
                        Text('- ${_currency.format(pricing["pointsDiscount"])}', style: const TextStyle(fontSize: 12, color: AppColors.brandYellow)),
                      ],
                    ),
                  ],
                  const Divider(color: AppColors.border, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(
                        _currency.format(pricing['total']),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() => _isSubmitting = true);
                        await Future.delayed(const Duration(milliseconds: 600));

                        await widget.appState.extendActiveReservation(
                          additionalHours: _additionalHours,
                          paymentMethod: _selectedPaymentMethod,
                          usePoints: _usePoints,
                          pointsToUse: user.loyaltyPoints,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Sewa diperpanjang +$_additionalHours Jam hingga ${_timeFormat.format(newEndTime)}!',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Konfirmasi & Bayar ${_currency.format(pricing["total"])}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
