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

// aqui seria interessante usar o state management, para não pedir para apagar o ponto várias vezes - o mesmo para o diálogo de editar

Future dialogEditPoint(
  BuildContext context,
  dynamic point,
  Function centralizar,
  List<dynamic> points,
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
          // CANCELAR:
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          // REMOVER PONTO:
          TextButton(
            onPressed: () async {
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
                        await pRepository.editPoint(individualPoint);
                        break;
                      }
                    }
                  }
                  // pra cada filho que esse ponto tiver, apaga ele no banco
                  for (PointChild individualPoint in point.children) {
                    await pRepository.deletePoint(
                        "child", individualPoint.uuid);
                  }
                } else if (point is PointChild) {
                  // se não é Parent então é Child, só precisa remover a referência do pai
                  for (PointModel individualPoint in points) {
                    if (individualPoint is PointParent) {
                      if (individualPoint.uuid == point.parentId) {
                        individualPoint.children.remove(point);
                        await pRepository.editPoint(individualPoint);
                        break;
                      }
                    }
                  }
                }

                if (point is PointParent) {
                  // await PointRepository().deletePoint("parent", point.uuid);
                  print("entrou aqui no pai");
                } else {
                  // await PointRepository().deletePoint("parent", point.uuid);
                  print(point);
                  print("entrou aqui no filho");
                }
                // points.remove(point);

                Navigator.pop(context);
              } on DioError catch (e) {
                showMessageError(context: context, text: e.message);
              }
            },
            child: const Text(
              "Remover",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          // EDITAR PONTO:
          TextButton(
            onPressed: () {
              print(point is PointParent?);
              print("\n");
              print(point is PointChild?);
              print("\n----");
              dialogEditar(context, point);
            },
            child: const Text(
              "Editar Ponto",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          // GERAR QR CODE:
          TextButton(
            onPressed: () {
              qrDialog(context, point);
            },
            child: const Text(
              "Gerar QRCode",
              style: TextStyle(color: Colors.green),
            ),
          ),
          // USAR COMO ANTERIOR:
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
          TextButton(
            onPressed: () {
              // Deveria voltar à tela do mapa mas agora com a opção de adicionar o ponto filho, que é independente dos 90º
            },
            child: const Text("Adicionar destino"),
          ),
        ],
      );
    },
  );
}
