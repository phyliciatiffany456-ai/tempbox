import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "../../models/locker_model.dart";
import "../../services/app_state.dart";
import "../../theme/app_theme.dart";
import "../../widgets/horizontal_choice_chip_scroller.dart";
import "../../widgets/map/interactive_gmap.dart";
import "locker_selection_screen.dart";

class LocationPickerScreen extends StatefulWidget {
  final AppState appState;

  const LocationPickerScreen({super.key, required this.appState});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isMapView = false;
  LockerLocation? _selectedMapLocation;

  final List<String> _categories = [
    'Semua',
    'Camping & Glamping',
    'Wisata Alam & Outdoor',
    'Shopping Mall',
    'Fasilitas Publik',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMapLocation = widget.appState.locations.first;
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint("Error opening Google Maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLocations = widget.appState.locations.where((loc) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          loc.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesQuery =
          loc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pilih Lokasi TEMPBOX'),
        actions: [
          IconButton(
            tooltip: _isMapView ? 'Lihat Daftar' : 'Lihat Peta (GMaps)',
            icon: Icon(
              _isMapView ? Icons.view_list_rounded : Icons.map_rounded,
            ),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: Column(
        children: [
          // View Mode Switcher Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isMapView = false),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isMapView
                            ? AppColors.coldAccent
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 16,
                            color: !_isMapView
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Daftar Lokasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !_isMapView
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isMapView = true),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isMapView
                            ? AppColors.coldAccent
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 16,
                            color: _isMapView
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Peta Interaktif (GMaps)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isMapView
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // If Map View is active
          if (_isMapView) ...[
            Expanded(child: _buildMapVisualView(filteredLocations)),
          ] else ...[
            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari lokasi wisata, camping, mall...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Category Chips
            HorizontalChoiceChipScroller(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((cat) {
                final isSel = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSel,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.coldAccent,
                  backgroundColor: AppColors.surfaceElevated,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSel ? AppColors.coldAccent : AppColors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Locations list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                itemCount: filteredLocations.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final loc = filteredLocations[i];
                  return _buildLocationCard(loc);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapVisualView(List<LockerLocation> locations) {
    final sel = _selectedMapLocation ?? locations.first;

    return Column(
      children: [
        // Quick Hub Selector Chips
        HorizontalChoiceChipScroller(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: locations.map((loc) {
            final isSel = loc.id == sel.id;
            final shortName = loc.name
                .replaceAll('TEMPBOX ', '')
                .replaceAll(' Hub', '');

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: isSel ? Colors.white : const Color(0xFFEA4335),
                  ),
                  const SizedBox(width: 4),
                  Text(shortName),
                ],
              ),
              selected: isSel,
              onSelected: (val) {
                if (val) setState(() => _selectedMapLocation = loc);
              },
              selectedColor: AppColors.coldAccent,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.white : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSel ? AppColors.coldAccent : AppColors.border,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Interactive Google Maps Container
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: buildInteractiveGMap(
              key: ValueKey('gmap-${sel.id}-${sel.latitude}-${sel.longitude}'),
              latitude: sel.latitude,
              longitude: sel.longitude,
              locationName: sel.name,
              onOpenMaps: () => _openGoogleMaps(sel.latitude, sel.longitude),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Bottom Selected Location Action Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sel.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sel.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${sel.distanceKm} km',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Button 1: Open Google Maps
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openGoogleMaps(sel.latitude, sel.longitude),
                      icon: const Icon(
                        Icons.directions_rounded,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'Google Maps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Button 2: Select this Locker
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.appState.selectedLocation = sel;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LockerSelectionScreen(
                              appState: widget.appState,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coldAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Pilih Loker Ini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(LockerLocation loc) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: AppColors.coldAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${loc.distanceKm} km',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              loc.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildSlotBadge(
                      '${loc.availableHot} Hot',
                      AppColors.hotAccent,
                    ),
                    const SizedBox(width: 6),
                    _buildSlotBadge(
                      '${loc.availableCold} Cold',
                      AppColors.coldAccent,
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Maps Button
                    InkWell(
                      onTap: () => _openGoogleMaps(loc.latitude, loc.longitude),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.directions_rounded,
                              size: 14,
                              color: Color(0xFFDC2626),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Maps',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Select Button
                    ElevatedButton(
                      onPressed: () {
                        widget.appState.selectedLocation = loc;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LockerSelectionScreen(
                              appState: widget.appState,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coldAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Pilih',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
