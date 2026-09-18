import "package:flutter/material.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";

class OperatorCloudScreen extends StatelessWidget {
  final AppState appState;

  const OperatorCloudScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Status Loker Pintar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard('Total Unit', '5 Unit', Icons.inventory_2_outlined, AppColors.coldAccent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiCard('Okupansi', '30.4%', Icons.pie_chart_outline_rounded, AppColors.brandYellow),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiCard('Kepatuhan Suhu', '99.8%', Icons.verified_outlined, AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Status Operasional Per Lokasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            _buildLocationUnitCard('TEMPBOX - Kintamani Glamping', '60.2°C', '3.9°C', 'Optimal'),
            const SizedBox(height: 8),
            _buildLocationUnitCard('TEMPBOX - Lembang Ecotourism', '59.8°C', '4.1°C', 'Optimal'),
            const SizedBox(height: 8),
            _buildLocationUnitCard('TEMPBOX - Grand Indonesia Mall', '61.0°C', '3.6°C', 'Optimal'),
            const SizedBox(height: 8),
            _buildLocationUnitCard('TEMPBOX - Siloam Medical Hub', '60.0°C', '4.0°C', 'Optimal'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLocationUnitCard(String name, String hotTemp, String coldTemp, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Hot: $hotTemp', style: const TextStyle(fontSize: 11, color: AppColors.hotAccent, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Text('Cold: $coldTemp', style: const TextStyle(fontSize: 11, color: AppColors.coldAccent, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
