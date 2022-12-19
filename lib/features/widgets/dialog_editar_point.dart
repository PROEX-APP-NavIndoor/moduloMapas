import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';

Future dialogEditar(
  BuildContext context,
  PointModel point,
) {
  return showDialog(
      context: context,
      builder: (context) {
        TypePoint type = TypePoint.common;
        String name = point.name;
        String descricao = point.description;
        return AlertDialog(
            title: const Text("Editar ponto"),
            content: Column(
              children: [
                Text("X = ${point.x}\nY = ${point.y}"),
                DropdownButtonFormField(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                      child: Text("Intermediário"),
                      value: TypePoint.passage,
                    ),
                    DropdownMenuItem(
                      child: Text("Caminho"),
                      value: TypePoint.common,
                    ),
                  ],
                  onChanged: (value) {
                    if (value != TypePoint.passage) {
                      name = "Caminho";
                      type = TypePoint.common;
                    } else {
                      name = "Passagem";
                      type = TypePoint.passage;
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
              TextButton(
                onPressed: () async {
                  point.name = name;
                  point.description = descricao;
                  if (kDebugMode) {
                    print(point.toJson());
                  }
                  try {
                    await PointRepository().editPoint(point);
                    Navigator.pop(context);
                  } on DioError catch (e) {
                    showMessageError(context: context, text: e.message);
                  }
                },
                child: const Text(
                  "Salvar",
                  style: TextStyle(color: Colors.green),
                ),
              )
            ]);
      });
}
