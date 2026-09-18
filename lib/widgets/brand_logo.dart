import "package:flutter/material.dart";

class TempBoxLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw outer flame (Red-Orange gradient)
    final flamePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final flamePath = Path();
    // Start at top flame tip
    flamePath.moveTo(w * 0.5, 0);
    // Right curve down
    flamePath.cubicTo(
      w * 0.85, h * 0.35,
      w * 1.0, h * 0.70,
      w * 0.5, h * 1.0,
    );
    // Left curve up
    flamePath.cubicTo(
      0, h * 0.70,
      w * 0.15, h * 0.35,
      w * 0.5, 0,
    );
    flamePath.close();

    canvas.drawPath(flamePath, flamePaint);

    // Draw inner cool droplet (Blue / Cyan)
    final dropPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF0288D1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.28, h * 0.42, w * 0.44, h * 0.48))
      ..style = PaintingStyle.fill;

    final dropPath = Path();
    dropPath.moveTo(w * 0.5, h * 0.42);
    dropPath.cubicTo(
      w * 0.72, h * 0.60,
      w * 0.70, h * 0.85,
      w * 0.5, h * 0.88,
    );
    dropPath.cubicTo(
      w * 0.30, h * 0.85,
      w * 0.28, h * 0.60,
      w * 0.5, h * 0.42,
    );
    dropPath.close();

    canvas.drawPath(dropPath, dropPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const BrandLogo({
    super.key,
    this.size = 28,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(size * 0.85, size),
              painter: TempBoxLogoPainter(),
            ),
            const SizedBox(width: 8),
            Text(
              'TEMPBOX',
              style: TextStyle(
                fontSize: size * 0.8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          const Text(
            'Smart & Sustainable Thermal Storage',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}
