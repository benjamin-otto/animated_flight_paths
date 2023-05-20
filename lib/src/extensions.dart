import 'dart:math' as math;

import 'package:flutter/material.dart';

extension NumX on num {
  num get squared => math.pow(this, 2);

  bool inExclusiveRange(num lowerBound, num upperBound) =>
      lowerBound < this && this < upperBound;

  bool inInclusiveRange(num lowerBound, num upperBound) =>
      lowerBound <= this && this <= upperBound;
}

extension OffsetX on Offset {
  Offset multiplyBySize(Size size) => Offset(
        dx * size.width,
        dy * size.height,
      );

  Offset clampToSize(Size size) => Offset(
        dx.clamp(0, size.width),
        dy.clamp(0, size.height),
      );
}

extension PathX on Path {
  void moveToFromOffset(Offset offset) => moveTo(offset.dx, offset.dy);

  void quadraticBezierToFromOffsets(Offset controlPoint, Offset endPoint) =>
      quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );
}
