import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FinancialScoreRing extends StatelessWidget {
  final int score; // 0 - 100
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final String? customLabel;

  const FinancialScoreRing({
    super.key,
    required this.score,
    this.size = 130,
    this.strokeWidth = 10,
    this.showLabel = true,
    this.customLabel,
  });

  Color get _scoreColor {
    if (score >= 80) return AppTheme.green;
    if (score >= 60) return AppTheme.cyan;
    if (score >= 40) return AppTheme.orange;
    return AppTheme.red;
  }

  String get _defaultLabel {
    if (score >= 80) return 'EXCELLENT';
    if (score >= 65) return 'HEALTHY';
    if (score >= 45) return 'FAIR';
    return 'ATTENTION';
  }

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0, 100);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ScoreRingPainter(
              progress: clampedScore / 100.0,
              strokeWidth: strokeWidth,
              activeColor: _scoreColor,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$clampedScore',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '/ 100',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: size * 0.10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    customLabel ?? _defaultLabel,
                    style: TextStyle(
                      color: _scoreColor,
                      fontSize: size * 0.08,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;

  _ScoreRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track paint (background)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 270 degree arc starting from 135 deg to 405 deg (bottom opening)
    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active progress arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          activeColor.withValues(alpha: 0.7),
          activeColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
}
