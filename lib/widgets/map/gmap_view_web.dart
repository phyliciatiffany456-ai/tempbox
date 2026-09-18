// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildInteractiveGMap({
  required Key key,
  required double latitude,
  required double longitude,
  required String locationName,
  required VoidCallback onOpenMaps,
}) {
  return _WebGMapView(
    key: key,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    onOpenMaps: onOpenMaps,
  );
}

class _WebGMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final VoidCallback onOpenMaps;

  const _WebGMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.onOpenMaps,
  });

  @override
  State<_WebGMapView> createState() => _WebGMapViewState();
}

class _WebGMapViewState extends State<_WebGMapView> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _registerIframe();
  }

  @override
  void didUpdateWidget(covariant _WebGMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _registerIframe();
    }
  }

  void _registerIframe() {
    final lat = widget.latitude.toStringAsFixed(4);
    final lng = widget.longitude.toStringAsFixed(4);
    _viewId = 'gmap-iframe-$lat-$lng';

    final embedUrl = 'https://maps.google.com/maps?q=$lat,$lng&hl=id&z=15&output=embed';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = embedUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'geolocation *';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
