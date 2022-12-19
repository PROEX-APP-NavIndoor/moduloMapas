import 'package:flutter/material.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';

class LinePainter extends CustomPainter {
  double coordInicialX = 0;
  double coordInicialY = 0;
  LinePainter({
    required this.coordInicialX,
    required this.coordInicialY,
  });

  @override
  void paint(Canvas canvas, size) {
    Paint paint = Paint();
    paint.color = Colors.green;
    paint.strokeWidth = 2;

    canvas.drawLine(
      Offset(coordInicialX, coordInicialY),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PathPainter extends CustomPainter {
  List<dynamic> pointList;
  PathPainter({
    required this.pointList,
  });

  double xVizinho = 0, yVizinho = 0;

  @override
  void paint(Canvas canvas, size) {
    Paint paintParent = Paint();
    paintParent.color = Colors.lightBlue;
    paintParent.strokeWidth = 2;

    Paint paintChild = Paint();
    paintChild.color = Colors.green;
    paintChild.strokeWidth = 2;

    // Desenha os pontos do caminho - exceto do ponto anterior
    for (var ponto in pointList) {
      if (ponto is PointParent) {
        for (var vizinho in ponto.neighbor) {
          if (vizinho["direction"] == "E" || vizinho["direction"] == "N") {
            for (PointModel vizinhoPonto in pointList) {
              if (vizinhoPonto.uuid == vizinho["id"]) {
                xVizinho = vizinhoPonto.x;
                yVizinho = vizinhoPonto.y;
                break;
              }
            }
            canvas.drawLine(
              Offset(ponto.x, ponto.y),
              Offset(xVizinho, yVizinho),
              paintParent,
            );
          }
        }
        if (ponto.children.isNotEmpty) {
          for (var filho in ponto.children) {
            canvas.drawLine(
              Offset(ponto.x, ponto.y),
              Offset(filho.x, filho.y),
              paintChild,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
