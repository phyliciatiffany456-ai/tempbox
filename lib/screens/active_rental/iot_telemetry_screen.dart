import "dart:async";
import "package:flutter/material.dart";
import "../../models/locker_model.dart";
import "../../models/telemetry_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../../widgets/temperature_gauge.dart";
import "../../widgets/extend_rental_sheet.dart";
import "../retrieval/retrieval_screen.dart";

class IotTelemetryScreen extends StatefulWidget {
  final AppState appState;
  final Reservation reservation;

  const IotTelemetryScreen({
    super.key,
    required this.appState,
    required this.reservation,
  });

  @override
  State<IotTelemetryScreen> createState() => _IotTelemetryScreenState();
}

class _IotTelemetryScreenState extends State<IotTelemetryScreen> {
  late Timer _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final active = widget.appState.activeReservation;
    final endTime = (active != null && active.id == widget.reservation.id)
        ? active.endTime
        : widget.reservation.endTime;
    final diff = endTime.difference(DateTime.now());
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final res = (widget.appState.activeReservation?.id == widget.reservation.id
            ? widget.appState.activeReservation
            : null) ??
        widget.reservation;
    final isHot = res.storageType == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;

    final telemetry = widget.appState.liveTelemetry ??
        LockerTelemetry(
          compartmentId: res.compartment.id,
          temperature: res.compartment.currentTemp,
          targetTemperature: res.compartment.targetTemp,
          humidity: isHot ? 35.0 : 62.0,
          isDoorLocked: !res.isDoorOpen,
          powerSource: 'Solar Hybrid',
          batteryLevel: 98,
          powerConsumptionWatts: 42.5,
          networkStatus: 'Online',
          lastUpdated: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Monitoring Suhu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kompartemen ${res.compartment.id} • ${res.location.name}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Temperature Gauge
            TemperatureGauge(
              currentTemp: telemetry.temperature,
              targetTemp: telemetry.targetTemperature,
              storageType: res.storageType,
              size: 200,
            ),
            const SizedBox(height: 16),

            // Stability tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: Color(0xFF15803D)),
                  SizedBox(width: 6),
                  Text(
                    'Suhu Stabil Terkontrol',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Essential Metrics (Kelembaban & Status Pintu)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Kelembaban',
                    value: '${telemetry.humidity.toStringAsFixed(0)}% RH',
                    icon: Icons.water_drop_outlined,
                    color: AppColors.coldAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pintu Loker',
                    value: telemetry.isDoorLocked ? 'Terkunci Aman' : 'Terbuka',
                    icon: telemetry.isDoorLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: telemetry.isDoorLocked ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Rental Countdown Timer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.brandYellow, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sisa Waktu Sewa',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          _formatDuration(_remaining),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Button to Extend Rental
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ExtendRentalSheet.show(context, widget.appState, res);
                },
                icon: const Icon(Icons.update_rounded, size: 20, color: AppColors.brandYellow),
                label: const Text(
                  'Perpanjang Sewa Loker',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brandYellow, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Button to Retrieval
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RetrievalScreen(
                        appState: widget.appState,
                        reservation: res,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Ambil Barang & Selesaikan Sewa',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
