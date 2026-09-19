import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:qr_flutter/qr_flutter.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../home/main_navigation_screen.dart";

class RetrievalScreen extends StatefulWidget {
  final AppState appState;
  final Reservation reservation;

  const RetrievalScreen({
    super.key,
    required this.appState,
    required this.reservation,
  });

  @override
  State<RetrievalScreen> createState() => _RetrievalScreenState();
}

class _RetrievalScreenState extends State<RetrievalScreen> {
  bool _isItemTaken = true;
  int _rating = 5;
  final _feedbackController = TextEditingController();
  bool _isFinalizing = false;
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _finishRental() async {
    if (!_isItemTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          content: Text('Harap centang konfirmasi bahwa barang telah diambil.'),
        ),
      );
      return;
    }

    setState(() => _isFinalizing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    widget.appState.completeRetrieval(
      rating: _rating.toDouble(),
      feedback: _feedbackController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isFinalizing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              'Sewa Selesai',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terima kasih telah menggunakan TEMPBOX. Kompartemen ${widget.reservation.compartment.id} telah ditutup dan siap untuk pengguna berikutnya.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (widget.appState.isMember) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: AppColors.brandYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '+${widget.reservation.pointsEarned} Poin Loyalty berhasil ditambahkan ke akun Anda!',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainNavigationScreen(appState: widget.appState),
                ),
                (route) => false,
              );
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.reservation;
    final isHot = res.storageType == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Pengambilan Barang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isHot ? Icons.whatshot_rounded : Icons.ac_unit_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res.location.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Kompartemen ${res.compartment.id} (${res.storageType.title})',
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QR & PIN Card for unlocking locker door to retrieve items
            Container(
              width: double.infinity,
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
                  const Text(
                    'Pindai QR / Masukkan PIN di Loker',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Arahkan QR ke scanner unit untuk membuka kunci pintu kompartemen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: QrImageView(
                      data: res.qrCodeData,
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PIN Akses: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          res.pinCode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Confirmation Checkbox
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isItemTaken,
                activeColor: AppColors.coldAccent,
                onChanged: (val) => setState(() => _isItemTaken = val ?? false),
                title: const Text(
                  'Saya telah mengambil seluruh barang bawaan saya dari loker.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Rating
            const Text(
              'Bagaimana pengalaman Anda?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNum = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starNum),
                  icon: Icon(
                    starNum <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.brandYellow,
                    size: 34,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _feedbackController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis ulasan singkat Anda (opsional)...',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Receipt Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildReceiptRow('No. Transaksi', res.reservationCode),
                  _buildReceiptRow('Metode Pembayaran', res.paymentMethod),
                  _buildReceiptRow('Durasi Total', '${res.durationHours} Jam'),
                  _buildReceiptRow(
                    'Total Pembayaran',
                    _currency.format(res.totalAmount),
                  ),
                  if (widget.appState.isMember) ...[
                    _buildReceiptRow(
                      'Poin Diperoleh',
                      '+${res.pointsEarned} Poin',
                      color: AppColors.brandYellow,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selesai Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFinalizing ? null : _finishRental,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coldAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isFinalizing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Konfirmasi & Selesaikan Sewa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String title,
    String val, {
    Color color = AppColors.textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
