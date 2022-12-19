import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:mvp_proex/features/svg_map/svg_map_flags.dart';
import 'package:mvp_proex/features/widgets/dialog_qrcode.widget.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dialog_editar_point.dart';

// aqui seria interessante usar o state management, para não pedir para apagar o ponto várias vezes - o mesmo para o diálogo de editar

Future dialogViewPoint(
  BuildContext context,
  var point,
  List<dynamic> points,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(children: [
            Text("Nome do Ponto: ${point.name}",
                style: const TextStyle(fontSize: 20)),
            SelectableText(
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
                if (point is PointParent) {
                  // se o ponto a ser removido é Parent, então ele tem vizinhos

                  for (Map<String, dynamic> vizinho in point.neighbor) {
                    // pra cada vizinho do ponto que desejo remover

                    for (PointModel individualPoint in points) {
                      // busca na lista até achar o vizinho atual
                      if (individualPoint is PointParent &&
                          individualPoint.uuid == vizinho["id"]) {
                        individualPoint.neighbor.removeWhere((item) =>
                            item["id"] ==
                            point
                                .uuid); // então remova a referência do meu ponto nele e atualiza o banco
                        await pRepository.editPoint(individualPoint);
                        break;
                      }
                    }
                  }
                  
                  for (PointChild individualPoint in point.children) { // pra cada filho que esse ponto tiver, apaga ele no banco
                    await pRepository.deletePoint(
                        "child", individualPoint.uuid);
                  }
                  await pRepository.deletePoint("parent", point.uuid);
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
                  await pRepository.deletePoint("child", point.uuid);
                } else {
                  if (kDebugMode) {
                    print("ERRO em dialog_edit_point.");
                    print(
                        "Tipo inesperado, esperado PointParent ou PointChild, recebido " +
                            point.runtimeType.toString());
                  }
                  throw ("Erro de tipo");
                }

                points.remove(point);
                Navigator.pop(context);
              } on DioError catch (e) {
                String textoErro = "";
                if (e.response != null) {
                  textoErro = e.response!.statusCode.toString();
                  textoErro += " - " + e.response!.statusMessage!;
                }
                try {
                  showMessageError(
                      context: context,
                      text: textoErro +
                          "\n" +
                          json.decode(e.response!.data)["message"]);
                } catch (f) {
                  showMessageError(context: context, text: textoErro);
                }
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
              dialogEditar(context, point);
            },
            child: const Text(
              "Editar Ponto",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              if (point is PointModel) {
                // ignore: avoid_print
                print(point.toJson());
              }
            },
            child: const Text(
              "Debug",
              style: TextStyle(color: Colors.blue),
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
              prefs.setString(
                "pontoAnterior",
                pointModelToJson(point),
              );

              Navigator.pop(context);
            },
            child: const Text(
              "Usar como anterior",
              style: TextStyle(color: Colors.green),
            ),
          ),
          if (point.uuid ==
              pointParentFromJson(prefs.getString("pontoAnterior") ?? "")
                  .uuid) ...[
            // ADICIONAR VIZINHO
            TextButton(
              onPressed: () {
                SvgMapFlags.modoAdicao = "vizinho";
                Navigator.pop(context);
              },
              child: const Text("Adicionar Vizinho"),
            ),
            // ADICIONAR FILHO
            TextButton(
              onPressed: () {
                SvgMapFlags.modoAdicao = "filho";
                SvgMapFlags.isLine = false;
                Navigator.pop(context);
              },
              child: const Text("Adicionar filho"),
            ),
          ]
        ],
      );
    },
  );
}
