import 'package:flutter/material.dart';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/widgets/dialog_qrcode.widget.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialog_editar.dart';

Future dialogEditPoint(
    BuildContext context,
    PointModel point,
    int id,
    String token,
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
          if (point.neighbor["next"] == null)
            TextButton(
              onPressed: () {
                //TODO: Testar se está dando certo
                // point.neighbor["prev"].remove(point.neighbor["next"]);
                PointRepository tempo = PointRepository();

                // tempo.editPoint(token, point.neighbor["prev"]);''
                points.remove(point);
                PointRepository().deletePoint(token, point.uuid);
                // TODO: esperar resposta do servidor
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
              SharedPreferences? prefs;
              SharedPreferences.getInstance().then((value) {
                prefs = value;
                prefs?.setString(
                  "pontoAnterior",
                  pointModelToJson(point),
                );

                print(prefs?.getString("pontoAnterior") ?? "");

                Navigator.pop(context);
              });
            },
            child: const Text(
              "Usar como anterior",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}
