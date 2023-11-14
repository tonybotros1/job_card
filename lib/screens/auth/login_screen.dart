import 'package:flutter/material.dart';

class CurvedScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100); // Start at the bottom-left
    path.quadraticBezierTo(size.width /5, size.height, size.width / 1.7,
        size.height - 50); // Create a quadratic Bezier curve
    path.lineTo(size.width, 0); // Finish at the top-right
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CurvedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipPath(
        clipper: CurvedScreenClipper(),
        child: Container(
          color: Colors.blue, // Background color
          height: 200, // Adjust the height as needed
        ),
      ),
    );
  }
}
