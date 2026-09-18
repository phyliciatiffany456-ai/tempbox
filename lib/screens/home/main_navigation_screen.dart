import "package:flutter/material.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "home_tab.dart";
import "../active_rental/active_rental_tab.dart";
import "../history/history_tab.dart";
import "../profile/profile_tab.dart";
import "../operator/operator_cloud_screen.dart";

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    required this.appState,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(appState: widget.appState),
      ActiveRentalTab(appState: widget.appState),
      HistoryTab(appState: widget.appState),
      ProfileTab(appState: widget.appState),
    ];

    final hasActive = widget.appState.activeReservation != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.coldAccent,
          unselectedItemColor: AppColors.textMuted,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.lock_clock_outlined),
                  if (hasActive)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.lock_clock_rounded),
              label: 'Loker Aktif',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: widget.appState.isMember ? 'Member' : 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
