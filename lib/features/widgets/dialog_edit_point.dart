import 'package:flutter/material.dart';
import 'package:dijkstra/dijkstra.dart';
import 'package:mvp_proex/features/widgets/dialog_point.widget.dart';
import 'package:mvp_proex/features/widgets/dialog_qrcode.widget.dart';
import 'package:mvp_proex/features/point/point.model.dart';

import 'dialog_editar.dart';

Future dialogEditPoint(
    BuildContext context,
    PointModel point,
    int id,
    int prev,
    int inicio,
    Function centralizar,
    var widget,
    List<PointModel> points,
    var graph) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(children: [
            Text("Nome do Ponto: ${point.name}",
                style: const TextStyle(fontSize: 20)),
            Text(
                "\nID do Ponto: ${point.id}\nX = ${point.x.toStringAsPrecision(6)}\nY = ${point.y.toStringAsPrecision(6)}\nDescrição: ${point.description}"),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              points.remove(point);

              Navigator.pop(context);
            },
            child: const Text(
              "Remover",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              dialogEditar(context, point);
            },
            child: const Text(
              "Editar Ponto",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              qrDialog(context, point);
            },
            child: const Text(
              "Gerar QRCode",
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              prev = point.id;
              Navigator.pop(context);
            },
            child: const Text(
              "Usar como anterior",
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            child: const Text(
              "Objetivo",
              style: TextStyle(color: Colors.deepPurple),
            ),
            onPressed: () async {
              // TODO: Caminho melhor
              // fechar pop up
              Navigator.pop(context);

              //onde estou
              int here = 0;

              for (var element in points) {
                if (element.x == widget.person.x &&
                    element.y == widget.person.y) {
                  here = element.id;
                }
              }

              // lista do caminho a ser seguido
              List tracker = Dijkstra.findPathFromGraph(graph, here, point.id);

              tracker.removeAt(0);

              for (var i = 0; i < tracker.length; i++) {
                widget.person.setx =
                    points.firstWhere((element) => element.id == tracker[i]).x;
                widget.person.sety =
                    points.firstWhere((element) => element.id == tracker[i]).y;
                inicio = tracker[i];
                await Future.delayed(const Duration(seconds: 3));
                centralizar(true);
              }

              // pegando o ponto inicial
              // Map pointInit = points
              //     .where((element) =>
              //         element["x"] == widget.person.x &&
              //         element["y"] == widget.person.y)
              //     .first;

              // // traçar o caminho, caso o caminho seja de volta
              // while (pointInit["id"] != point["id"]) {
              //   tracker.add(point);
              //   point = points.where((element) => element["id"] == point["prev"]).first;
              // }

              // tracker = tracker.reversed.toList();

              // print(tracker);

              // for (var i = 0; i < tracker.length; i++) {
              //   widget.person.setx = tracker[i]["x"];
              //   widget.person.sety = tracker[i]["y"];
              //   inicio = tracker[i]["id"];
              //   await Future.delayed(const Duration(seconds: 2));
              //   centralizar(true);
              // }
            },
          ),
        ],
      );
    },
  );
}
