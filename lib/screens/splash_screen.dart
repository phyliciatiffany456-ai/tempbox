import "package:flutter/material.dart";
import "../services/app_state.dart";
import "../theme/app_theme.dart";
import "../widgets/brand_logo.dart";
import "auth/auth_screen.dart";
import "home/main_navigation_screen.dart";

class SplashScreen extends StatelessWidget {
  final AppState appState;

  const SplashScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const BrandLogo(size: 68, showTagline: true),
              const SizedBox(height: 28),
              const Text(
                'Loker pintar bersuhu presisi untuk menjaga kesegaran dan kehangatan makanan atau minuman Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 3),

              // Button 1: Mode Tamu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    appState.continueAsGuest();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainNavigationScreen(appState: appState),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coldAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Reservasi Cepat (Tamu)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Button 2: Member
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(appState: appState),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.coldAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk / Daftar Member',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coldAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Member mendapatkan Loyalty Poin dan diskon sewa di setiap transaksi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
