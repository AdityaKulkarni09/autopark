import 'package:flutter/material.dart';

class Clip1Clipper extends CustomClipper<Path> {
  @override
  Path getClip (Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);


    return path;
  }
  @override
  bool shouldReclip (CustomClipper<Path> oldClipper) => true;
}