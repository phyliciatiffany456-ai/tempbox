import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:url_launcher/url_launcher.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../../widgets/compartment_box.dart";
import "payment_screen.dart";

class LockerSelectionScreen extends StatefulWidget {
  final AppState appState;

  const LockerSelectionScreen({super.key, required this.appState});

  @override
  State<LockerSelectionScreen> createState() => _LockerSelectionScreenState();
}

class _LockerSelectionScreenState extends State<LockerSelectionScreen> {
  late StorageType _storageType;
  late int _durationHours;
  Compartment? _selectedCompartment;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _storageType = widget.appState.selectedStorageType;
    _durationHours = widget.appState.selectedDurationHours;
    final comps = widget.appState.getCompartmentsForSelection();
    _selectedCompartment = comps.firstWhere((c) => c.isAvailable, orElse: () => comps[0]);
    widget.appState.selectedCompartment = _selectedCompartment;
  }

  void _onStorageTypeChanged(StorageType type) {
    setState(() {
      _storageType = type;
      widget.appState.selectedStorageType = type;
      final comps = widget.appState.getCompartmentsForSelection();
      _selectedCompartment = comps.firstWhere((c) => c.isAvailable, orElse: () => comps[0]);
      widget.appState.selectedCompartment = _selectedCompartment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.appState.selectedLocation ?? widget.appState.locations[0];
    final compartments = widget.appState.getCompartmentsForSelection();
    final now = DateTime.now();
    final pricing = widget.appState.calculatePricing(
      hours: _durationHours,
      startTime: now,
      applyMemberDiscount: true,
    );

    final isHot = _storageType == StorageType.hot;
    final accentColor = isHot ? AppColors.hotAccent : AppColors.coldAccent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pilih Loker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.coldAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Text(
                          location.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Buka di Google Maps',
                    icon: const Icon(Icons.directions_rounded, color: Color(0xFFDC2626), size: 22),
                    onPressed: () async {
                      final url = Uri.parse(location.googleMapsUrl);
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        debugPrint("Error opening GMaps: $e");
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Storage Mode Toggle (Hot vs Cold)
            const Text(
              'Tipe Penyimpanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStorageToggleOption(
                    type: StorageType.hot,
                    title: 'Hot Storage',
                    temp: '55°C - 65°C',
                    desc: '${location.availableHot} loker tersedia',
                    icon: Icons.whatshot_rounded,
                    accent: AppColors.hotAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStorageToggleOption(
                    type: StorageType.cold,
                    title: 'Cold Storage',
                    temp: '2°C - 6°C',
                    desc: '${location.availableCold} loker tersedia',
                    icon: Icons.ac_unit_rounded,
                    accent: AppColors.coldAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Locker Compartment Matrix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nomor Kompartemen',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  '${isHot ? location.availableHot : location.availableCold} dari 6 Tersedia',
                  style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Grid of 6 compartments
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: compartments.length,
              itemBuilder: (context, i) {
                final comp = compartments[i];
                final isSelected = _selectedCompartment?.id == comp.id;
                return CompartmentBox(
                  compartment: comp,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedCompartment = comp;
                      widget.appState.selectedCompartment = comp;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Duration Selector
            const Text(
              'Durasi Sewa',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...[1, 2, 3, 4, 6, 8, 12, 24].map((hours) {
                    final isSel = _durationHours == hours;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('$hours Jam'),
                        selected: isSel,
                        onSelected: (val) {
                          setState(() {
                            _durationHours = hours;
                            widget.appState.selectedDurationHours = hours;
                          });
                        },
                        selectedColor: accentColor,
                        backgroundColor: AppColors.surfaceElevated,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSel ? accentColor : AppColors.border,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Custom Duration Stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Durasi Kustom:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                    color: AppColors.textPrimary,
                    onPressed: _durationHours > 1
                        ? () {
                            setState(() {
                              _durationHours--;
                              widget.appState.selectedDurationHours = _durationHours;
                            });
                          }
                        : null,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '$_durationHours Jam',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: accentColor,
                      ),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                    color: AppColors.textPrimary,
                    onPressed: () {
                      setState(() {
                        _durationHours++;
                        widget.appState.selectedDurationHours = _durationHours;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Clean Price Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Biaya',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  _buildPriceRow('Tarif Sewa', '${_currency.format(pricing["hourlyRate"])} / jam'),
                  _buildPriceRow('Durasi', '$_durationHours Jam'),
                  _buildPriceRow('Subtotal', _currency.format(pricing["subtotal"])),
                  if (widget.appState.isMember) ...[
                    _buildPriceRow(
                      'Diskon Member (10%)',
                      '- ${_currency.format(pricing["discount"])}',
                      textColor: AppColors.success,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        _currency.format(pricing["total"]),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  if (widget.appState.isMember) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Mendapatkan +${pricing["pointsEarned"]} Poin Loyalty',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandYellow,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(appState: widget.appState),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Lanjut ke Pembayaran',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageToggleOption({
    required StorageType type,
    required String title,
    required String temp,
    required String desc,
    required IconData icon,
    required Color accent,
  }) {
    final isSel = _storageType == type;
    return InkWell(
      onTap: () => _onStorageTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? accent.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? accent : AppColors.border,
            width: isSel ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accent, size: 22),
                if (isSel)
                  Icon(Icons.check_circle_rounded, color: accent, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSel ? accent : AppColors.textPrimary,
              ),
            ),
            Text(
              temp,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
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

  Widget _buildPriceRow(String label, String value, {Color textColor = AppColors.textSecondary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}
