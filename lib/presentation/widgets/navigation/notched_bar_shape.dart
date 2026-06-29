import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Builds the top-notched pill path used by the floating bottom tab bar.
class NotchedBarShape {
  NotchedBarShape._();

  static const double gapRadius = 38;
  static const double shoulderRadius = 10;

  static Path build({
    required double width,
    required double height,
    required double cornerRadius,
    required double paddingTop,
  }) {
    final path = Path();
    final cx = width / 2;
    final fabCenterY = paddingTop + 6;
    final dy = fabCenterY - shoulderRadius;
    final dx2 = math.pow(gapRadius + shoulderRadius, 2) - dy * dy;

    if (dx2 > 0) {
      final dx = math.sqrt(dx2);
      final xsLeft = cx - dx;
      final xsRight = cx + dx;
      final ratio = shoulderRadius / (gapRadius + shoulderRadius);
      final txLeft = xsLeft + dx * ratio;
      final tyLeft = shoulderRadius + dy * ratio;
      final txRight = xsRight - dx * ratio;
      final tyRight = shoulderRadius + dy * ratio;
      final r = cornerRadius;

      if (r > 0) {
        path
          ..moveTo(r, 0)
          ..lineTo(xsLeft, 0)
          ..arcToPoint(
            Offset(txLeft, tyLeft),
            radius: const Radius.circular(shoulderRadius),
            clockwise: true,
          )
          ..arcToPoint(
            Offset(txRight, tyRight),
            radius: const Radius.circular(gapRadius),
            clockwise: false,
          )
          ..arcToPoint(
            Offset(xsRight, 0),
            radius: const Radius.circular(shoulderRadius),
            clockwise: true,
          )
          ..lineTo(width - r, 0)
          ..arcToPoint(Offset(width, r), radius: Radius.circular(r))
          ..lineTo(width, height - r)
          ..arcToPoint(Offset(width - r, height), radius: Radius.circular(r))
          ..lineTo(r, height)
          ..arcToPoint(Offset(0, height - r), radius: Radius.circular(r))
          ..lineTo(0, r)
          ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
          ..close();
      } else {
        path
          ..moveTo(0, 0)
          ..lineTo(xsLeft, 0)
          ..arcToPoint(
            Offset(txLeft, tyLeft),
            radius: const Radius.circular(shoulderRadius),
            clockwise: true,
          )
          ..arcToPoint(
            Offset(txRight, tyRight),
            radius: const Radius.circular(gapRadius),
            clockwise: false,
          )
          ..arcToPoint(
            Offset(xsRight, 0),
            radius: const Radius.circular(shoulderRadius),
            clockwise: true,
          )
          ..lineTo(width, 0)
          ..lineTo(width, height)
          ..lineTo(0, height)
          ..close();
      }
    } else if (cornerRadius > 0) {
      final r = cornerRadius;
      path
        ..moveTo(r, 0)
        ..lineTo(width - r, 0)
        ..arcToPoint(Offset(width, r), radius: Radius.circular(r))
        ..lineTo(width, height - r)
        ..arcToPoint(Offset(width - r, height), radius: Radius.circular(r))
        ..lineTo(r, height)
        ..arcToPoint(Offset(0, height - r), radius: Radius.circular(r))
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    } else {
      path.addRect(Rect.fromLTWH(0, 0, width, height));
    }

    return path;
  }
}

class NotchedBarPainter extends CustomPainter {
  final double cornerRadius;
  final double paddingTop;
  final Color fillColor;
  final Color borderColor;

  NotchedBarPainter({
    required this.cornerRadius,
    required this.paddingTop,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = NotchedBarShape.build(
      width: size.width,
      height: size.height,
      cornerRadius: cornerRadius,
      paddingTop: paddingTop,
    );

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant NotchedBarPainter oldDelegate) {
    return oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.paddingTop != paddingTop ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
