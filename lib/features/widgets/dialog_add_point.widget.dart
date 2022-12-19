import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'dart:convert';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:mvp_proex/features/svg_map/svg_map_flags.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/point/point.model.dart';

Future dialogAddPoint(BuildContext context, var details, String mapId) {
  return showDialog(
    context: context,
    builder: (context) {
      String tipo = SvgMapFlags.modoAdicao;
      String name = "Ponto";
      String descricao = "Descrição";
      return AlertDialog(
        title: tipo == "filho"
            ? const Text("Adicionar ponto filho")
            : const Text("Adicionar ponto pai"),
        content: Column(
          children: [
            Text(
                "X = ${details.localPosition.dx}\nY = ${details.localPosition.dy}"),
            DropdownButtonFormField(
              value: tipo,
              items: SvgMapFlags.modoAdicao == "caminho"
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
                  : SvgMapFlags.modoAdicao == "filho"
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
          // CANCELAR
          TextButton(
            onPressed: () {
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
                String directionAnterior = "";
                PointParent pontoAnterior = PointParent();

                if (SvgMapFlags.modoAdicao != "inicial") {
                  //usando esse point model para que seja possível acessar os valores do ponto com o uuid desejado
                  pontoAnterior = pointParentFromJson(
                      prefs.getString("pontoAnterior") ?? "");
                }

                // inicialização é feita dentro do if else
                // ignore: prefer_typing_uninitialized_variables
                var point;
                if (SvgMapFlags.modoAdicao == "filho") {
                  point = PointChild();
                } else {
                  point = PointParent();
                }

                point.x = details.localPosition.dx;
                point.y = details.localPosition.dy;
                point.name = name;
                point.description = descricao;
                point.mapId = mapId;
                if (point is PointParent) {
                  switch (tipo) {
                    case "passagem":
                      point.type = TypePoint.passage;
                      break;
                    case "inicial":
                      point.type = TypePoint.entrance;
                      break;
                    default:
                      point.type = TypePoint.common;
                      break;
                  }
                  if (SvgMapFlags.modoAdicao != "inicial") {
                    // verificar a orientação
                    double difx = (point.x - pontoAnterior.x);
                    double dify = (point.y - pontoAnterior.y);
                    String direction;
                    if (difx < 0) difx *= -1;
                    if (dify < 0) dify *= -1;
                    if (difx < 2) point.x = pontoAnterior.x;
                    if (dify < 2) point.y = pontoAnterior.y;

                    if (point.x == pontoAnterior.x) {
                      if (pontoAnterior.y < point.y) {
                        direction = "N";
                        directionAnterior = "S";
                      } else {
                        direction = "S";
                        directionAnterior = "N";
                      }
                    } else {
                      if (pontoAnterior.x < point.x) {
                        direction = "W";
                        directionAnterior = "E";
                      } else {
                        direction = "E";
                        directionAnterior = "W";
                      }
                    }
                    point.neighbor.add(
                      {"id": pontoAnterior.uuid, "direction": direction},
                    );
                  }
                } else if (point is PointChild) {
                  switch (tipo) {
                    case "obstaculo":
                      point.isObstacle = true;
                      break;
                    default:
                      point.isObstacle = false;
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
                  await pRepository
                      .postPoint(
                          point is PointParent ? "parent" : "child", point)
                      .then((value) async {
                    point.uuid = json.decode(value)["id"];

                    if (SvgMapFlags.modoAdicao != "filho") {
                      prefs.setString(
                        "pontoAnterior",
                        pointModelToJson(point),
                      );
                      if (SvgMapFlags.modoAdicao == "caminho") {
                        pontoAnterior.neighbor.add(
                            {"id": point.uuid, "direction": directionAnterior});
                        await pRepository.editPoint(pontoAnterior);
                      }
                    } else if (SvgMapFlags.modoAdicao == "filho") {
                      pontoAnterior.children.add(point);
                    }

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
