import 'package:flutter/material.dart';

List<Positioned> pointValidWidget({
  required double x,
  required double y,
  required double width,
  required double height,
  required isValidX,
  required isValidY,
}) {
  return [
    Positioned(
      top: y,
      left: 0,
      child: Container(
        width: width,
        height: 1,
        decoration: BoxDecoration(
          color: isValidY
                  ? Colors.green
                  : Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    Positioned(
      top: 0,
      left: x,
      child: Container(
        width: 1,
        height: height,
        decoration: BoxDecoration(
          color: isValidX
                  ? Colors.green
                  : Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
  ];
}
