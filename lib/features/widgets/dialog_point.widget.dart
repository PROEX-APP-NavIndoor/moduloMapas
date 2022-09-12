import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/point/point.model.dart';

Future dialogPointWidget(
  BuildContext context,
  var details,
  int id,
  List<PointModel> points,
  var graph,
  String token,
) {
  return showDialog(
    context: context,
    builder: (context) {
      bool breakPoint = false;
      String name = "Caminho";
      String descricao = "Descrição";
      return AlertDialog(
        title: Text("Adicionar ponto $id"),
        content: Column(
          children: [
            Text(
                "X = ${details.localPosition.dx}\nY = ${details.localPosition.dy}"),
            DropdownButtonFormField(
              value: breakPoint,
              items: const [
                DropdownMenuItem(
                  child: Text("Objetivo"),
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
                  breakPoint = false;
                } else {
                  name = "Objetivo";
                  breakPoint = true;
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
                  name = "Ponto $id";
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
          TextButton(
              onPressed: () async {
                /* Calcular o peso das distâncias com base na diferença das coordenadas */
                SharedPreferences prefs = await SharedPreferences.getInstance();

                int prev = (prefs.getInt('prev') ?? 1);

                int peso = ((details.localPosition.dx - points[prev-1].x).abs() +
                        (details.localPosition.dy - points[prev-1].y).abs())
                    .round();
                print("peso = $peso");
                print(details.localPosition.dx);
                print(details.localPosition.dy);
                print(points[prev-1].x.abs());
                print(points[prev-1].y.abs());

                PointModel point = PointModel();
                point.id = id;
                point.x = details.localPosition.dx;
                point.y = details.localPosition.dy;
                point.description = descricao;
                point.breakPoint = breakPoint;
                point.name = name;
                point.neighbor = {}; //colocar o peso aqui
                point.mapId = "7aae38c8-1ac5-4c52-bd5d-648a8625209d";
                // TODO: pegar o mapId do mapa atual
                // Esse mapId em teoria era pra existir no mapa aqui, mas tecnicamente ele não está registrado no banco, então não existe

                Map<String, dynamic> jsonnn = {
                  "id": id,
                  "x": details.localPosition.dx,
                  "y": details.localPosition.dy,
                  "descricao": descricao,
                  /*Sempre existirá ao menos um vizinho, que é o ponto anterior*/
                  "vizinhos": {prev++: peso},
                  "breakPoint": breakPoint,
                  "name": name
                };

                /* O ponto anterior a este deve conter o novo ponto */
                graph[prev - 2] = points[prev - 2].neighbor;

                graph.putIfAbsent(id, () => jsonnn["vizinhos"]);
                points.add(point);

                id++;
                await prefs.setInt('prev', id);
                // print(points);
                // print(graph);

                List<String> myList = (prefs.getStringList('tracker') ?? []);
                List<int> myOriginaList =
                    myList.map((i) => int.parse(i)).toList();
                print('Your list  $myOriginaList');

                // //TODO: remover esse comentário abaixo?
                // int usuarioPos = (prefs.getInt('pos') ?? 0);
                // print('Usuario pos $usuarioPos');

                PointRepository pRepository = PointRepository();
                pRepository
                    .postPoint(
                        token, point) // TODO: receber o token pelo provider
                    .then((res) {
                  point.uuid = json.decode(res)["id"];
                });

                Navigator.pop(context);
              },
              child: const Text("Adicionar")),
        ],
      );
    },
  );
}
