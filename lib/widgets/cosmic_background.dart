import 'dart:ui';
import 'package:flutter/material.dart';

class CosmicBackground extends StatelessWidget {
  final Widget child;

  const CosmicBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF070D1A),
                Color(0xFF0A1022),
                Color(0xFF070B16),
              ],
            ),
          ),
        ),

        Positioned(
          top: -100,
          right: -80,
          child: _glow(
            const Color(0xFF7657FF),
            220,
          ),
        ),

        Positioned(
          bottom: -100,
          left: -80,
          child: _glow(
            const Color(0xFF42D9FF),
            220,
          ),
        ),

        child,
      ],
    );
  }

  Widget _glow(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 70,
        sigmaY: 70,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}