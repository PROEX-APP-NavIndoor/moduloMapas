import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Um vetor de mapas é mapeado para um vetor de pointWidgets
// O ponto é dado pelo json, mas para ser mostrado no mapa ele precisa estar como PointWidget
// Precisamos que o ponto seja dado por um model
// Teremos então ao invés de um vetor de mapas, um vetor de PointModels
// Depois se mapeia então os pointModels para PointWidgets

class PointWidget extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final point;
  final double side;
  final Function()? onPressed;
  final String idPontoAnterior;

  const PointWidget(
      {Key? key, required this.point, required this.side, this.onPressed, required this.idPontoAnterior})
      : super(key: key);

  @override
  State<PointWidget> createState() => _PointWidgetState();
}

class _PointWidgetState extends State<PointWidget> {
  SharedPreferences? prefs;
  PointModel? pontoAnterior;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getColor() {
      if (widget.point is PointChild) {
        return Colors.green;
      } else if (widget.point is PointParent) {
        if (widget.point.uuid == widget.idPontoAnterior) {
          return Colors.yellow;
        }
        switch (widget.point.type) {
          case TypePoint.common:
            return Colors.red;
          case TypePoint.passage:
            return Colors.orange;
          case TypePoint.initial:
            return Colors.blue;
          default:
            return Colors.yellow;
        }
      } else {
        if (kDebugMode) {
          print("ERRO em point.widget.\nTipo inesperado, esperado PointChild ou PointParent, recebido \"" + widget.point.runtimeType.toString() + "\".");
        }
        return Colors.pink;
      }
    }

    return Positioned(
      top: widget.point.y - widget.side / 2,
      left: widget.point.x - widget.side / 2,
      child: InkWell(
        onTap:
            kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows
                ? widget.onPressed
                : null,
        child: Container(
          color: getColor(),
          width: widget.side,
          height: widget.side,
        ),
      ),
    );
  }
}
