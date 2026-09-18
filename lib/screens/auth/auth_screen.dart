import "package:flutter/material.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../home/main_navigation_screen.dart";

class AuthScreen extends StatefulWidget {
  final AppState appState;

  const AuthScreen({super.key, required this.appState});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController(text: 'Tiffany Phylicia');
  final _emailController = TextEditingController(text: 'tiffany@tempbox.id');
  final _phoneController = TextEditingController(text: '081258294859');
  bool _isLoginMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.appState.loginAsMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Selamat Datang ${_nameController.text.split(" ").first}! Anda mendapatkan 250 Loyalty Poin.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(appState: widget.appState),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Masuk' : 'Daftar Akun Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple Member Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.brandYellow, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Daftar member untuk menikmati diskon sewa 10% dan kumpulkan Loyalty Poin.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_isLoginMode) ...[
              _buildInputField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama Anda',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
            ],

            _buildInputField(
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              label: 'Nomor WhatsApp',
              hint: '0812xxxxxxx',
              icon: Icons.phone_android_rounded,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coldAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isLoginMode ? 'Masuk' : 'Daftar Sekarang',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(
                  _isLoginMode
                      ? 'Belum punya akun? Daftar di sini'
                      : 'Sudah punya akun? Masuk di sini',
                  style: const TextStyle(color: AppColors.coldAccent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: TextButton(
                onPressed: () {
                  widget.appState.continueAsGuest();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainNavigationScreen(appState: widget.appState),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Lanjut sebagai Tamu',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.coldAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
