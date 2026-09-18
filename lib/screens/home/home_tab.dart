import "package:flutter/material.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../../widgets/brand_logo.dart";
import "../auth/auth_screen.dart";
import "../reservation/location_picker_screen.dart";
import "../reservation/locker_selection_screen.dart";
import "../active_rental/qr_access_screen.dart";

class HomeTab extends StatelessWidget {
  final AppState appState;

  const HomeTab({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final activeRes = appState.activeReservation;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BrandLogo(size: 28),
              if (user.isMember) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.brandYellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${user.loyaltyPoints} Pts',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(appState: appState),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Daftar Member',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coldAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // User Greeting
          Text(
            'Halo, ${user.isMember ? user.name.split(" ").first : "Tamu"} 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            user.isMember
                ? 'Pilih loker pintar untuk kebutuhan Anda hari ini.'
                : 'Mode Tamu aktif. Reservasi cepat tanpa pendaftaran.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),

          // Active Locker Card (if any)
          if (activeRes != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: activeRes.storageType == StorageType.hot
                      ? AppColors.hotAccent
                      : AppColors.coldAccent,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activeRes.storageType == StorageType.hot
                                ? Icons.whatshot_rounded
                                : Icons.ac_unit_rounded,
                            color: activeRes.storageType == StorageType.hot
                                ? AppColors.hotAccent
                                : AppColors.coldAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Loker Aktif',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          activeRes.compartment.id,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${activeRes.location.name} • ${activeRes.storageType.title}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrAccessScreen(
                              appState: appState,
                              reservation: activeRes,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeRes.storageType == StorageType.hot
                            ? AppColors.hotAccent
                            : AppColors.coldAccent,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Buka QR Akses Loker', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Storage Cards (Hot vs Cold)
          const Text(
            'Sewa Loker',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStorageCard(
                  context: context,
                  type: StorageType.hot,
                  title: 'Hot Storage',
                  temp: '55°C - 65°C',
                  desc: 'Makanan hangat',
                  color: AppColors.hotAccent,
                  icon: Icons.whatshot_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStorageCard(
                  context: context,
                  type: StorageType.cold,
                  title: 'Cold Storage',
                  temp: '2°C - 6°C',
                  desc: 'Minuman dingin & obat',
                  color: AppColors.coldAccent,
                  icon: Icons.ac_unit_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nearby Locations Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lokasi Terdekat',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPickerScreen(appState: appState),
                    ),
                  );
                },
                child: const Text('Lihat Semua', style: TextStyle(color: AppColors.coldAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          _buildLocationItem(context, appState.locations[0]),
          const SizedBox(height: 8),
          _buildLocationItem(context, appState.locations[1]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStorageCard({
    required BuildContext context,
    required StorageType type,
    required String title,
    required String temp,
    required String desc,
    required Color color,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        appState.selectedStorageType = type;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPickerScreen(appState: appState),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            ),
            Text(
              temp,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(BuildContext context, LockerLocation loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        dense: true,
        onTap: () {
          appState.selectedLocation = loc;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LockerSelectionScreen(appState: appState),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on_rounded, color: AppColors.coldAccent, size: 18),
        ),
        title: Text(loc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text('${loc.distanceKm} km • ${loc.availableHot + loc.availableCold} tersedia',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
      ),
    );
  }
}
