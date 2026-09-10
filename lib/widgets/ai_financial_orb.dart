import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiFinancialOrb extends StatefulWidget {
  final double size;
  final bool isPulsing;
  final Color primaryGlow;
  final Color secondaryGlow;

  const AiFinancialOrb({
    super.key,
    this.size = 56,
    this.isPulsing = true,
    this.primaryGlow = AppTheme.purple,
    this.secondaryGlow = AppTheme.cyan,
  });

  @override
  State<AiFinancialOrb> createState() => _AiFinancialOrbState();
}

class _AiFinancialOrbState extends State<AiFinancialOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulseScale = 1.0 + (t * 0.08);
        final glowOpacity = 0.35 + (t * 0.30);

        return SizedBox(
          width: widget.size * 1.25,
          height: widget.size * 1.25,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow
              Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: widget.size * 1.15,
                  height: widget.size * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryGlow.withValues(alpha: glowOpacity * 0.6),
                        blurRadius: widget.size * 0.45,
                        spreadRadius: widget.size * 0.08,
                      ),
                      BoxShadow(
                        color: widget.secondaryGlow.withValues(alpha: glowOpacity * 0.4),
                        blurRadius: widget.size * 0.35,
                        spreadRadius: widget.size * 0.04,
                      ),
                    ],
                  ),
                ),
              ),

              // Rotating orbital particle track
              Transform.rotate(
                angle: t * 2 * math.pi,
                child: SizedBox(
                  width: widget.size * 1.1,
                  height: widget.size * 1.1,
                  child: CustomPaint(
                    painter: _OrbitalRingPainter(
                      glowColor: widget.secondaryGlow.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              // Inner spherical orb
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.3),
                    radius: 0.85,
                    colors: [
                      Colors.white,
                      widget.secondaryGlow,
                      widget.primaryGlow,
                      const Color(0xFF0F0B26),
                    ],
                    stops: const [0.0, 0.25, 0.70, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.32,
                    height: widget.size * 0.32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitalRingPainter extends CustomPainter {
  final Color glowColor;

  _OrbitalRingPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint = Paint()
      ..color = glowColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, paint);

    // Two orbiting highlight nodes
    final nodePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx + radius, center.dy), 2.2, nodePaint);
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 1.6, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) => true;
}
