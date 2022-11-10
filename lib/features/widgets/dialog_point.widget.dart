import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'dart:convert';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/point/point.model.dart';

Future dialogPointWidget(
  BuildContext context,
  var details,
) {
  // Essa adição é apenas de pontos pai
  return showDialog(
    context: context,
    builder: (context) {
      bool intermediary = false;
      String name = "Caminho";
      String descricao = "Descrição";
      return AlertDialog(
        title: const Text("Adicionar ponto"),
        content: Column(
          children: [
            Text(
                "X = ${details.localPosition.dx}\nY = ${details.localPosition.dy}"),
            DropdownButtonFormField(
              value: intermediary,
              items: const [
                DropdownMenuItem(
                  child: Text("Intermediário"),
                  value: true,
                ),
                DropdownMenuItem(
                  child: Text("Caminho"),
                  value: false,
                ),
              ],
              onChanged: (value) {
                if (value != true) {
                  name = "Caminho";
                  intermediary = false;
                } else {
                  name = "Intermediário";
                  intermediary = true;
                }
              },
            ),
            TextFormField(
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLength: 80,
              initialValue: name,
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
              initialValue: descricao,
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
                // Calcular o peso das distâncias com base na diferença das coordenadas
                SharedPreferences prefs = await SharedPreferences.getInstance();

                //usando esse point model para que seja possível acessar os valores do ponto com o uuid desejado
                // como só pode ser adicionado pontos pai por aqui então sempre vai haver um vizinho, então esse ponto anterior sempre vai ser um PointParent
                PointParent pontoAnterior =
                    pointParentFromJson(prefs.getString("pontoAnterior") ?? "");

                // O peso ainda é necessário?
                // int peso = ((details.localPosition.dx - pontoAnterior.x).abs() +
                //         (details.localPosition.dy - pontoAnterior.y).abs())
                //     .round();
                // print("peso = $peso");
                // print(details.localPosition.dx);
                // print(details.localPosition.dy);

                PointParent point = PointParent(neighbor: []);

                point.x = details.localPosition.dx;
                point.y = details.localPosition.dy;
                point.description = descricao;
                point.type =
                    intermediary ? TypePoint.intermediary : TypePoint.common;
                point.name = name;
                // verificar a orientação
                point.neighbor.add({"id": pontoAnterior.uuid});
                point.mapId =
                    "c5e47fab-0a29-4d79-be62-ae3320629dbd"; // TODO: pegar o mapId do mapa atual
                // Esse mapId em teoria era pra existir no mapa aqui, mas tecnicamente ele não está registrado no banco, então não existe

                PointRepository pRepository = PointRepository();

                try {
                  await pRepository.postPoint("parent", point).then((value) {
                    point.uuid = json.decode(value)["id"];
                    prefs.setString(
                      "pontoAnterior",
                      pointModelToJson(point),
                    );
                    pontoAnterior.neighbor.add({"id": point.uuid});
                    // pontoAnterior.neighbors = {
                    //   "prev": pontoAnterior.neighbors[0]["id"],
                    //   "next": point.uuid
                    // };
                    pRepository.editPoint(pontoAnterior).then((value) {
                      print(pontoAnterior.neighbor);
                      Navigator.pop(context, point);
                    });
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
