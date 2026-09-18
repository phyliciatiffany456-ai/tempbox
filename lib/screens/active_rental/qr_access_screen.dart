import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:qr_flutter/qr_flutter.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../../widgets/extend_rental_sheet.dart";
import "iot_telemetry_screen.dart";
import "../retrieval/retrieval_screen.dart";

class QrAccessScreen extends StatelessWidget {
  final AppState appState;
  final Reservation reservation;
  final bool isNewlyCreated;

  const QrAccessScreen({
    super.key,
    required this.appState,
    required this.reservation,
    this.isNewlyCreated = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final res = (appState.activeReservation?.id == reservation.id ? appState.activeReservation : null) ?? reservation;
        final isHot = res.storageType == StorageType.hot;
        final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;
        final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Akses Loker'),
        leading: isNewlyCreated
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Success Message if new
            if (isNewlyCreated) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pembayaran Berhasil! Silakan gunakan QR di bawah untuk membuka kompartemen.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // QR Ticket Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              res.location.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Kode: ${res.reservationCode}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          res.compartment.id,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // QR Code Graphic
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: res.qrCodeData,
                      version: QrVersions.auto,
                      size: 190.0,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PIN Code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PIN Akses: ',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  const SizedBox(height: 10),
                  const Text(
                    'Arahkan QR Code ini ke scanner unit TEMPBOX untuk membuka kompartemen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),

                  // Time info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeInfo('Mulai', timeFormat.format(res.startTime)),
                      Container(width: 1, height: 20, color: AppColors.border),
                      _buildTimeInfo('Selesai', timeFormat.format(res.endTime)),
                      Container(width: 1, height: 20, color: AppColors.border),
                      _buildTimeInfo('Target Suhu', '${res.compartment.targetTemp.toStringAsFixed(0)}°C'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action: View Temperature Monitoring
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IotTelemetryScreen(
                        appState: appState,
                        reservation: reservation,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.thermostat_rounded, size: 20),
                label: const Text(
                  'Lihat Suhu & Status Loker',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coldAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Action: Extend Rental (Perpanjang Sewa)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ExtendRentalSheet.show(context, appState, res);
                },
                icon: const Icon(Icons.update_rounded, size: 20),
                label: const Text(
                  'Perpanjang Sewa Loker',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandYellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Action: Retrieve Item
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RetrievalScreen(
                        appState: appState,
                        reservation: res,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.outbox_rounded, size: 18, color: AppColors.textPrimary),
                label: const Text(
                  'Ambil Barang Sekarang',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
