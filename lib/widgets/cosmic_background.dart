import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const CosmicBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 12),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return _buildStaticBackground(0.0);
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) => _buildStaticBackground(_controller!.value),
    );
  }

  Widget _buildStaticBackground(double progress) {
    // Subtle breathing offsets
    final double orb1X = math.sin(progress * 2 * math.pi) * 35;
    final double orb1Y = math.cos(progress * 2 * math.pi) * 35;
    final double orb2X = math.cos(progress * 2 * math.pi) * -40;
    final double orb2Y = math.sin(progress * 2 * math.pi) * -40;
    final double orb3X = math.sin((progress + 0.5) * 2 * math.pi) * 30;

    return Stack(
      children: [
        // Deep Space Obsidian Foundation
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF03050B),
                Color(0xFF070B16),
                Color(0xFF050811),
                Color(0xFF080C1A),
              ],
            ),
          ),
        ),

        // Ambient Nebula Stardust Canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _StardustPainter(progress: progress),
          ),
        ),

        // Dreamy Aurora Orb 1: Luminous Electric Violet
        Positioned(
          top: -90 + orb1Y,
          right: -70 + orb1X,
          child: _glow(
            const Color(0xFF7C4DFF),
            320,
            0.18 + (math.sin(progress * math.pi) * 0.05),
          ),
        ),

        // Dreamy Aurora Orb 2: Ethereal Cyan Aqua
        Positioned(
          bottom: -110 + orb2Y,
          left: -80 + orb2X,
          child: _glow(
            const Color(0xFF00E5FF),
            320,
            0.16 + (math.cos(progress * math.pi) * 0.04),
          ),
        ),

        // Dreamy Aurora Orb 3: Cosmic Magenta / Orchid Center Beam
        Positioned(
          top: 280 + orb3X,
          right: -100,
          child: _glow(
            const Color(0xFFE040FB),
            260,
            0.11 + (math.sin((progress + 0.3) * math.pi) * 0.03),
          ),
        ),

        // Subdued emerald pulse in bottom right
        Positioned(
          bottom: 120 + orb1X,
          right: -90 + orb2Y,
          child: _glow(
            const Color(0xFF00E676),
            240,
            0.08,
          ),
        ),

        widget.child,
      ],
    );
  }

  Widget _glow(Color color, double size, double opacity) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 85,
        sigmaY: 85,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _StardustPainter extends CustomPainter {
  final double progress;

  _StardustPainter({required this.progress});

  // Deterministic star particle seeds for consistent beauty
  static final List<math.Point<double>> _stars = List.generate(48, (i) {
    final rand = math.Random(i * 37 + 19);
    return math.Point(rand.nextDouble(), rand.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      final x = star.x * size.width;
      final y = star.y * size.height;

      // Twinkle calculation
      final twinklePhase = (progress * 4 + (i * 0.35)) % (2 * math.pi);
      final alpha = (0.2 + (0.45 * (0.5 + 0.5 * math.sin(twinklePhase)))).clamp(0.08, 0.7);

      Color starColor = Colors.white;
      if (i % 3 == 0) {
        starColor = const Color(0xFF80D8FF); // cyan tint
      } else if (i % 4 == 0) {
        starColor = const Color(0xFFEA80FC); // lilac tint
      }

      paint.color = starColor.withValues(alpha: alpha);
      final radius = (i % 5 == 0) ? 1.6 : (i % 2 == 0 ? 1.2 : 0.8);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StardustPainter oldDelegate) => true;
}