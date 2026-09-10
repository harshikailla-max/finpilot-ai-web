import 'dart:ui';
import 'package:flutter/material.dart';

class AiOrb extends StatelessWidget {
  final double size;

  const AiOrb({
    super.key,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7657FF),
                  Color(0xFF42D9FF),
                ],
              ),
            ),
          ),
        ),

        Container(
          width: size * 0.72,
          height: size * 0.72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFB7F5FF),
                Color(0xFF7657FF),
                Color(0xFF21184D),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ),
      ],
    );
  }
}