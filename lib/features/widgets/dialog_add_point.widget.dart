import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'dart:convert';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/point/point.model.dart';

Future dialogAddPoint(BuildContext context, var details, String modoAdicao) {
  return showDialog(
    context: context,
    builder: (context) {
      String tipo = modoAdicao;
      String name = "Ponto";
      String descricao = "Descrição";
      return AlertDialog(
        title: modoAdicao == "filho"
            ? const Text("Adicionar ponto filho")
            : const Text("Adicionar ponto pai"),
        content: Column(
          children: [
            Text(
                "X = ${details.localPosition.dx}\nY = ${details.localPosition.dy}"),
            DropdownButtonFormField(
              value: tipo,
              items: modoAdicao == "caminho"
                  ? const [
                      DropdownMenuItem(
                        child: Text("Caminho"),
                        value: "caminho",
                      ),
                      DropdownMenuItem(
                        child: Text("Passagem"),
                        value: "passagem",
                      ),
                    ]
                  : modoAdicao == "filho"
                      ? const [
                          DropdownMenuItem(
                            child: Text("Destino"),
                            value: "filho",
                          ),
                          DropdownMenuItem(
                            child: Text("Obstáculo"),
                            value: "obstaculo",
                          ),
                        ]
                      : const [
                          DropdownMenuItem(
                            child: Text("Inicial"),
                            value: "inicial",
                          ),
                        ],
              onChanged: (value) {
                tipo = value as String;
              },
            ),
            TextFormField(
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: "Nome do ponto",
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  name = "Ponto";
                } else {
                  name = value;
                }
              },
            ),
            TextFormField(
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLength: 250,
              decoration: const InputDecoration(
                labelText: "Descrição do ponto",
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  descricao = "Descrição";
                } else {
                  descricao = value;
                }
              },
            )
          ],
        ),
        scrollable: true,
        actions: [
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("modoAdicao", "caminho");
              Navigator.pop(context);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          // ADICIONAR
          TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                //usando esse point model para que seja possível acessar os valores do ponto com o uuid desejado
                PointParent pontoAnterior =
                    pointParentFromJson(prefs.getString("pontoAnterior") ?? "");

                // inicialização é feita dentro do if else
                // ignore: prefer_typing_uninitialized_variables
                var point;
                if (modoAdicao == "filho") {
                  point = PointChild();
                } else {
                  point = PointParent();
                }

                point.x = details.localPosition.dx;
                point.y = details.localPosition.dy;
                point.name = name;
                point.description = descricao;
                point.mapId =
                    "c5e47fab-0a29-4d79-be62-ae3320629dbd"; // TODO: pegar o mapId do mapa atual
                if (point is PointParent) {
                  switch (tipo) {
                    case "caminho":
                      point.type = TypePoint.common;
                      break;
                    case "passage":
                      point.type = TypePoint.passage;
                      break;
                    case "initial":
                      point.type = TypePoint.initial;
                      break;
                    default:
                      break;
                  }
                  // verificar a orientação
                  point.neighbor.add({"id": pontoAnterior.uuid});
                } else if (point is PointChild) {
                  switch (tipo) {
                    case "filho":
                      point.isObstacle = false;
                      break;
                    case "obstaculo":
                      point.isObstacle = true;
                      break;
                    default:
                      break;
                  }
                  point.parentId = pontoAnterior.uuid;
                } else {
                  // ignore: avoid_print
                  print("ERRO de tipo em dialog_point.widget.");
                  throw ("Erro de tipo");
                }

                PointRepository pRepository = PointRepository();

                try {
                  print(point.toJson());
                  await pRepository
                      .postPoint(
                          point is PointParent ? "parent" : "child", point)
                      .then((value) async {
                    point.uuid = json.decode(value)["id"];

                    if (modoAdicao == "caminho") {
                      prefs.setString(
                        "pontoAnterior",
                        pointModelToJson(point),
                      );
                      pontoAnterior.neighbor.add({"id": point.uuid});
                    } else if (modoAdicao == "filho") {
                      print(point.toJson());
                      pontoAnterior.children.add(point);
                      print(pontoAnterior.children);
                      print(pontoAnterior.toJson());
                    }

                    await pRepository.editPoint(pontoAnterior);
                    Navigator.pop(context, point);
                  });
                } on DioError catch (e) {
                  //TODO: arrumar mensagem de erro
                  //quando vem uma message ela está vindo como string, e não como mapa, porém é possível que venha como html, e nesse caso não teria como dar json decode nela
                  try {
                    showMessageError(
                      context: context,
                      text: e.message +
                          " " +
                          e.response!.statusMessage! +
                          "\n" +
                          e.response!.data,
                    );
                  } catch (f) {
                    showMessageError(
                      context: context,
                      text: e.message + " " + e.response!.statusMessage!,
                    );
                  }
                }
              },
              child: const Text("Adicionar")),
        ],
      );
    },
  );
}
