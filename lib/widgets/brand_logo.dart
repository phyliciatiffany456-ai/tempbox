import "package:flutter/material.dart";

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const BrandLogo({super.key, this.size = 28, this.showTagline = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: size * 0.70,
                height: size,
                child: Image.asset(
                  'assets/images/tempbox_flame.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'Logo TempBox',
                ),
              ),
              SizedBox(width: size * 0.13),
              Text(
                'TEMPBOX',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: size * 0.72,
                  fontWeight: FontWeight.w800,
                  letterSpacing: size * 0.014,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          const Text(
            'Smart & Sustainable Thermal Storage',
            style: TextStyle(
              fontFamily: 'Poppins',
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
