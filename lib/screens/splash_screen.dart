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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final isCompact = constraints.maxHeight < 640;
            final horizontalPadding = isNarrow ? 16.0 : 24.0;
            final verticalPadding = isCompact ? 16.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 560,
                    minHeight: (constraints.maxHeight - (verticalPadding * 2))
                        .clamp(0.0, double.infinity)
                        .toDouble(),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        BrandLogo(
                          size: isNarrow ? 54 : (isCompact ? 60 : 68),
                          showTagline: true,
                        ),
                        SizedBox(height: isCompact ? 20 : 28),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: const Text(
                            'Loker pintar bersuhu presisi untuk menjaga kesegaran dan kehangatan makanan atau minuman Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Spacer(flex: isCompact ? 2 : 3),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              appState.continueAsGuest();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainNavigationScreen(appState: appState),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.coldAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Reservasi Cepat (Tamu)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AuthScreen(appState: appState),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.coldAccent,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Masuk / Daftar Member',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.coldAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Member mendapatkan Loyalty Poin dan diskon sewa di setiap transaksi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
