import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:mvp_proex/features/widgets/dialog_qrcode.widget.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialog_editar.dart';

Future dialogEditPoint(
  BuildContext context,
  var point,
  int id,
  Function centralizar,
  var widget,
  List<PointModel> points,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(children: [
            Text("Nome do Ponto: ${point.name}",
                style: const TextStyle(fontSize: 20)),
            Text(
                "\nID do Ponto: ${point.uuid}\nX = ${point.x.toStringAsPrecision(6)}\nY = ${point.y.toStringAsPrecision(6)}\nDescrição: ${point.description}"),
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
            onPressed: () async {
              //TODO: Testar se está dando certo

              // ao remover um ponto, tirar a referência à ele em qualquer ponto que tenha ele como vizinho, e remover os filhos, atualizar esses pontos no banco, e então remover esse ponto do banco
              PointRepository pRepository = PointRepository();
              try {
                // se o ponto a ser removido é Parent, então ele tem vizinhos
                if (point is PointParent) {
                  // pra cada vizinho do ponto que desejo remover
                  for (Map<String, dynamic> vizinho in point.neighbors) {
                    // busca na lista até achar o vizinho atual
                    for (PointModel individualPoint in points) {
                      if (individualPoint is PointParent &&
                          individualPoint.uuid == vizinho["id"]) {
                        // então remova a referência do meu ponto nele e atualiza o banco
                        individualPoint.neighbors
                            .removeWhere((item) => item["id"] == point.uuid);
                        pRepository.editPoint(individualPoint);
                        break;
                      }
                    }
                  }
                  // pra cada filho que esse ponto tiver, apaga ele no banco
                  for (PointChild individualPoint in point.children) {
                    pRepository.deletePoint(individualPoint.uuid);
                  }
                } else if (point is PointChild) {
                  // se não é Parent então é Children, só precisa remover a referência do pai
                  for (PointModel individualPoint in points) {
                    if (individualPoint is PointParent) {
                      if (individualPoint.uuid == point.parentId) {
                        individualPoint.children.remove(point);
                        pRepository.editPoint(individualPoint);
                        break;
                      }
                    }
                  }
                }

                points.remove(point);
                PointRepository().deletePoint(point.uuid);

                Navigator.pop(context);
              } on DioError catch (e) {
                //TODO: arrumar mensagem de erro
                showMessageError(
                    context: context,
                    text: e.message + e.response?.data['message']);
              }
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

                print(prefs?.getString("pontoAnterior") ?? "PONTO NULO");

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
