import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Um vetor de mapas é mapeado para um vetor de pointWidgets
// O ponto é dado pelo json, mas para ser mostrado no mapa ele precisa estar como PointWidget
// Precisamos que o ponto seja dado por um model
// Teremos então ao invés de um vetor de mapas, um vetor de PointModels
// Depois se mapeia então os pointModels para PointWidgets

class PointWidget extends StatefulWidget {
  final PointModel point;
  final double side;
  final Function()? onPressed;
  const PointWidget(
      {Key? key, required this.point, required this.side, this.onPressed})
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
      SharedPreferences.getInstance().then((value) {
        prefs = value;
        pontoAnterior =
            pointModelFromJson(prefs?.getString("pontoAnterior") ?? "");
      });

      if (widget.point.breakPoint) {
        return Colors.green;
      } else if (widget.point.uuid == pontoAnterior?.uuid) {
        return Colors.yellow;
      }
      return Colors.red;
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
