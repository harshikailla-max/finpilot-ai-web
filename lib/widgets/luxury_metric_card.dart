import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'luxury_card.dart';

class MiniSparklineChart extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final Color? fillColor;
  final double height;
  final double strokeWidth;

  const MiniSparklineChart({
    super.key,
    required this.dataPoints,
    this.lineColor = AppTheme.cyan,
    this.fillColor,
    this.height = 36,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          points: dataPoints,
          lineColor: lineColor,
          fillColor: fillColor ?? lineColor.withValues(alpha: 0.15),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;

  _SparklinePainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal == 0) ? 1.0 : (maxVal - minVal);

    final stepX = size.width / (points.length - 1);
    final path = Path();
    final fillPath = Path();

    double getY(double val) {
      final normalized = (val - minVal) / range;
      // Invert Y so highest value is near top (with 4px padding)
      return size.height - (normalized * (size.height - 8)) - 4;
    }

    path.moveTo(0, getY(points[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(points[0]));

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * stepX;
      final y1 = getY(points[i]);
      final x2 = (i + 1) * stepX;
      final y2 = getY(points[i + 1]);

      final midX = (x1 + x2) / 2;
      path.cubicTo(midX, y1, midX, y2, x2, y2);
      fillPath.cubicTo(midX, y1, midX, y2, x2, y2);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw area fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

class LuxuryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? deltaText;
  final bool isPositiveDelta;
  final IconData? icon;
  final Color accentColor;
  final List<double>? sparklineData;
  final VoidCallback? onTap;

  const LuxuryMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.deltaText,
    this.isPositiveDelta = true,
    this.icon,
    this.accentColor = AppTheme.purple,
    this.sparklineData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (deltaText != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isPositiveDelta ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: isPositiveDelta ? AppTheme.green : AppTheme.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  deltaText!,
                  style: TextStyle(
                    color: isPositiveDelta ? AppTheme.green : AppTheme.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (sparklineData != null && sparklineData!.isNotEmpty) ...[
            const SizedBox(height: 12),
            MiniSparklineChart(
              dataPoints: sparklineData!,
              lineColor: accentColor,
            ),
          ],
        ],
      ),
    );
  }
}

class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.white,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
