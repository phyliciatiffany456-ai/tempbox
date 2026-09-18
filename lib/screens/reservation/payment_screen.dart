import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:qr_flutter/qr_flutter.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../active_rental/qr_access_screen.dart";

class PaymentScreen extends StatefulWidget {
  final AppState appState;

  const PaymentScreen({super.key, required this.appState});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'QRIS';
  bool _isProcessing = false;
  bool _usePoints = false;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'QRIS',
      'name': 'QRIS',
      'desc': 'GoPay, OVO, ShopeePay, Dana, Mobile Banking',
      'icon': Icons.qr_code_scanner_rounded,
    },
    {
      'id': 'GoPay',
      'name': 'GoPay',
      'desc': 'Saldo GoPay instan',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'BCA VA',
      'name': 'BCA Virtual Account',
      'desc': 'Transfer otomatis verifikasi',
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': 'Mandiri VA',
      'name': 'Mandiri Livin',
      'desc': 'Transfer Virtual Account',
      'icon': Icons.credit_card_rounded,
    },
  ];

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final res = widget.appState.createReservation(
      paymentMethod: _selectedMethod,
      usePoints: _usePoints,
      pointsToUse: widget.appState.currentUser.loyaltyPoints,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => QrAccessScreen(
          appState: widget.appState,
          reservation: res,
          isNewlyCreated: true,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    final comp = widget.appState.selectedCompartment ??
        widget.appState.getCompartmentsForSelection().first;
    final loc = widget.appState.selectedLocation ?? widget.appState.locations[0];
    final hours = widget.appState.selectedDurationHours;
    
    final pricing = widget.appState.calculatePricing(
      hours: hours,
      startTime: DateTime.now(),
      applyMemberDiscount: true,
      pointsToUse: _usePoints ? user.loyaltyPoints : 0,
    );

    final isHot = widget.appState.selectedStorageType == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          loc.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          comp.id,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.appState.selectedStorageType.title} • $hours Jam',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        _currency.format(pricing["total"]),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Loyalty Points Redemption Card
            if (widget.appState.isMember && user.loyaltyPoints > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _usePoints ? AppColors.brandYellow : AppColors.border,
                    width: _usePoints ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.brandYellow, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gunakan Poin Loyalitas (${user.loyaltyPoints} Poin)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Potongan -Rp ${user.loyaltyPoints} (1 Poin = Rp 1)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
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
              const SizedBox(height: 16),
            ],

            // Pricing Breakdown Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildCostRow('Subtotal Sewa ($hours Jam)', _currency.format(pricing["subtotal"])),
                  if (pricing["discount"]! > 0)
                    _buildCostRow('Diskon Member (10%)', '- ${_currency.format(pricing["discount"])}', color: AppColors.success),
                  if (_usePoints && pricing["pointsDiscount"]! > 0)
                    _buildCostRow('Tukar ${pricing["pointsUsed"]} Poin', '- ${_currency.format(pricing["pointsDiscount"])}', color: AppColors.brandYellow),
                  const Divider(color: AppColors.border, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        _currency.format(pricing["total"]),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  if (widget.appState.isMember) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Poin didapat: +${pricing["pointsEarned"]} Poin (Rp 1.000 = 1 Poin)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brandYellow),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            // Payment Methods List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (context, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final method = _paymentMethods[i];
                final isSelected = _selectedMethod == method['id'];
                return InkWell(
                  onTap: () => setState(() => _selectedMethod = method['id'] as String),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.coldAccent.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.coldAccent : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.coldAccent.withOpacity(0.12) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: isSelected ? AppColors.coldAccent : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['name'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                method['desc'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.coldAccent : AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // QRIS Display if selected
            if (_selectedMethod == 'QRIS') ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'QRIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: 'https://tempbox.id/pay/qris?amount=${pricing["total"]}',
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currency.format(pricing["total"]),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coldAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Bayar Sekarang (${_currency.format(pricing["total"])})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String val, {Color color = AppColors.textPrimary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
