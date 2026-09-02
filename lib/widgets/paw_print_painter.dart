import 'package:flutter/material.dart';

/// Huella de pata dibujada a mano, usada como placeholder de foto y
/// como logo. Antes estaba duplicada en tres pantallas distintas.
class PawPrintPainter extends CustomPainter {
  final Color color;
  const PawPrintPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.55, height: h * 0.42), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.22, h * 0.28), width: w * 0.24, height: h * 0.3), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.42, h * 0.12), width: w * 0.24, height: h * 0.32), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.64, h * 0.12), width: w * 0.24, height: h * 0.32), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.82, h * 0.28), width: w * 0.22, height: h * 0.28), paint);
  }

  @override
  bool shouldRepaint(covariant PawPrintPainter oldDelegate) => oldDelegate.color != color;
}
