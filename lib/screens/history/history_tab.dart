import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../reservation/location_picker_screen.dart";

class HistoryTab extends StatelessWidget {
  final AppState appState;

  const HistoryTab({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final history = appState.history;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded, size: 32, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Belum Ada Riwayat',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Riwayat transaksi sewa loker Anda akan tercatat di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationPickerScreen(appState: appState),
                          ),
                        );
                      },
                      child: const Text('Sewa Loker Sekarang'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = history[i];
                final isHot = item.storageType == StorageType.hot;
                final accent = isHot ? AppColors.hotAccent : AppColors.coldAccent;

                return Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.reservationCode,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(fontSize: 10, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isHot ? Icons.whatshot_rounded : Icons.ac_unit_rounded,
                              color: accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.location.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Kompartemen ${item.compartment.id} (${item.storageType.title})',
                                  style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(item.startTime),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          Text(
                            currency.format(item.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      if (item.pointsEarned > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.stars_rounded, size: 14, color: AppColors.brandYellow),
                            const SizedBox(width: 4),
                            Text(
                              '+${item.pointsEarned} Poin Didapat',
                              style: const TextStyle(fontSize: 11, color: AppColors.brandYellow, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
