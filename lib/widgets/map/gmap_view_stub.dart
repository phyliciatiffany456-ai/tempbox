import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

Widget buildInteractiveGMap({
  required Key key,
  required double latitude,
  required double longitude,
  required String locationName,
  required VoidCallback onOpenMaps,
}) {
  return _StubGMapView(
    key: key,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    onOpenMaps: onOpenMaps,
  );
}

class _StubGMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final VoidCallback onOpenMaps;

  const _StubGMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.onOpenMaps,
  });

  @override
  State<_StubGMapView> createState() => _StubGMapViewState();
}

class _StubGMapViewState extends State<_StubGMapView> {
  double _zoom = 15.0;
  Offset _panOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _panOffset += details.delta;
          });
        },
        child: Container(
          color: const Color(0xFFE5E7EB),
          child: Stack(
            children: [
              // Map background grid mimicking Google Maps
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(offset: _panOffset, zoom: _zoom),
                ),
              ),

              // Center Marker
              Center(
                child: Transform.translate(
                  offset: _panOffset,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hub_rounded, size: 12, color: AppColors.coldAccent),
                            const SizedBox(width: 4),
                            Text(
                              widget.locationName,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.location_pin,
                        size: 38,
                        color: Color(0xFFEA4335), // Google Maps Red
                      ),
                    ],
                  ),
                ),
              ),

              // Google Maps Watermark badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded, size: 12, color: Color(0xFF4285F4)),
                      SizedBox(width: 4),
                      Text('Google Maps API', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),

              // Zoom controls
              Positioned(
                right: 12,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in_btn',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: () => setState(() => _zoom = (_zoom + 1).clamp(10.0, 20.0)),
                      child: const Icon(Icons.add, size: 18),
                    ),
                    const SizedBox(height: 6),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out_btn',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: () => setState(() => _zoom = (_zoom - 1).clamp(10.0, 20.0)),
                      child: const Icon(Icons.remove, size: 18),
                    ),
                    const SizedBox(height: 6),
                    FloatingActionButton.small(
                      heroTag: 'recenter_btn',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4285F4),
                      onPressed: () => setState(() => _panOffset = Offset.zero),
                      child: const Icon(Icons.my_location, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Offset offset;
  final double zoom;

  _MapGridPainter({required this.offset, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = (zoom / 4).clamp(3.0, 8.0);

    final linePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0;

    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx + 40, offset.dy + 30, 90, 80),
        const Radius.circular(12),
      ),
      parkPaint,
    );

    final waterPaint = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawCircle(Offset(offset.dx + size.width - 60, offset.dy + 70), 50, waterPaint);

    // Grid lines
    final step = 40.0;
    for (double x = (offset.dx % step); x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = (offset.dy % step); y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Main road
    canvas.drawLine(
      Offset(0, size.height / 2 + offset.dy * 0.2),
      Offset(size.width, size.height / 2 + offset.dy * 0.2),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.zoom != zoom;
}
