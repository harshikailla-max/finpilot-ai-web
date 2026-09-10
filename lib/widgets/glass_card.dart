import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 22,
    this.backgroundColor,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderGradient = borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            const Color(0xFF5FE1FF).withValues(alpha: 0.16),
            const Color(0xFF9E7CFF).withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.04),
          ],
        );

    Widget cardWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF7C6CFF).withValues(alpha: 0.05),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: CustomPaint(
            foregroundPainter: _GradientBorderPainter(
              borderRadius: borderRadius,
              strokeWidth: borderWidth,
              gradient: effectiveBorderGradient,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFF0D1424).withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gradient != gradient;
}