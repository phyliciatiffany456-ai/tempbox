import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../auth/auth_screen.dart";

class ProfileTab extends StatelessWidget {
  final AppState appState;

  const ProfileTab({super.key, required this.appState});

  Color _getTierColor(String tier) {
    if (tier.contains('Platinum')) return const Color(0xFF7C3AED);
    if (tier.contains('Diamond')) return const Color(0xFF0284C7);
    if (tier.contains('Gold')) return const Color(0xFFD97706);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final user = appState.currentUser;
        final isMember = user.isMember;
        final tierColor = _getTierColor(user.membershipTier);

        // Progress Tier calculation
        double tierProgress = 0.0;
        String nextTierName = 'Gold Member';
        String progressSubtitle = '';
        final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

        if (user.totalSpending >= 10000000) {
          tierProgress = 1.0;
          nextTierName = 'Platinum';
          progressSubtitle = 'Maksimal! Anda telah mencapai tier tertinggi.';
        } else if (user.totalSpending >= 5000000) {
          nextTierName = 'Platinum Member';
          final progressInTier = user.totalSpending - 5000000;
          tierProgress = (progressInTier / 5000000).clamp(0.0, 1.0);
          final remaining = 10000000 - user.totalSpending;
          progressSubtitle = '${currencyFormat.format(remaining)} lagi ke $nextTierName';
        } else if (user.totalSpending >= 1000000) {
          nextTierName = 'Diamond Member';
          final progressInTier = user.totalSpending - 1000000;
          tierProgress = (progressInTier / 4000000).clamp(0.0, 1.0);
          final remaining = 5000000 - user.totalSpending;
          progressSubtitle = '${currencyFormat.format(remaining)} lagi ke $nextTierName';
        } else {
          nextTierName = 'Gold Member';
          tierProgress = (user.totalSpending / 1000000).clamp(0.0, 1.0);
          final remaining = 1000000 - user.totalSpending;
          progressSubtitle = '${currencyFormat.format(remaining)} lagi ke $nextTierName';
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Akun & Profil'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                // User / Member Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMember ? tierColor.withOpacity(0.4) : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMember
                                  ? tierColor.withOpacity(0.12)
                                  : AppColors.surfaceElevated,
                            ),
                            child: Icon(
                              isMember ? Icons.stars_rounded : Icons.person_outline_rounded,
                              color: isMember ? tierColor : AppColors.textSecondary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isMember ? user.phone : 'Mode Tamu',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (isMember)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tierColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tierColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                user.membershipTier,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tierColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 12),

                      if (isMember) ...[
                        Row(
                          children: [
                            Expanded(child: _buildStatCol('Poin Loyalty', '${user.loyaltyPoints}', AppColors.brandYellow)),
                            Container(width: 1, height: 24, color: AppColors.border),
                            Expanded(child: _buildStatCol('Diskon Sewa', '10%', AppColors.success)),
                            Container(width: 1, height: 24, color: AppColors.border),
                            Expanded(child: _buildStatCol('Tier', user.membershipTier.replaceAll(' Member', ''), tierColor)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border.withOpacity(0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progres ${user.membershipTier}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${(tierProgress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: tierColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: tierProgress,
                                  minHeight: 7,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                progressSubtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Daftar akun member untuk mendapatkan diskon sewa dan mengumpulkan Loyalty Poin.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthScreen(appState: appState),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coldAccent),
                            child: const Text('Daftar / Masuk Member'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

            // Referral Card
            if (isMember) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Referral Anda',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.referralCode,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.coldAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: user.referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Kode Referral disalin!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Salin', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Customer Support
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
                  const Text('Bantuan & Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  _buildHelpItem(
                    Icons.chat_bubble_outline_rounded,
                    'WhatsApp Customer Support',
                    '+62 812-5829-4859',
                  ),
                  const Divider(color: AppColors.border, height: 16),
                  _buildHelpItem(
                    Icons.mail_outline_rounded,
                    'Email Support',
                    'support@tempbox.id',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (isMember) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    appState.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kembali ke Mode Tamu.')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Keluar dari Akun Member', style: TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.coldAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
