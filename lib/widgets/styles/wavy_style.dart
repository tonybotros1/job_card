import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height * 0.9); // Start the path near the bottom
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.8,
        size.width * 0.2, size.height * 0.7); // Create the wavy curve
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9,
        size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width, size.height); // Draw to the bottom right corner
    path.lineTo(0, size.height); // Draw to the bottom left corner
    path.close(); // Complete the path

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
