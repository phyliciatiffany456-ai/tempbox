import "package:flutter/material.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../reservation/location_picker_screen.dart";
import "qr_access_screen.dart";

class ActiveRentalTab extends StatelessWidget {
  final AppState appState;

  const ActiveRentalTab({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final active = appState.activeReservation;

    if (active != null) {
      return QrAccessScreen(
        appState: appState,
        reservation: active,
        isNewlyCreated: false,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Loker Aktif'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceElevated,
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  size: 36,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Loker yang Disewa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih lokasi terdekat dan sewa kompartemen Hot atau Cold Storage sesuai kebutuhan Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                child: const Text('Mulai Sewa Loker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
