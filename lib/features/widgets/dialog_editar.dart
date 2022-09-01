import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point.repository.dart';

Future dialogEditar(
  BuildContext context,
  var point,
) {
  return showDialog(
      context: context,
      builder: (context) {
        String token =
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Inlnb3JAdW5pZmVpLmJyIiwiaWF0IjoxNjYxOTk1MzYyLCJleHAiOjE2NjIwODE3NjIsInN1YiI6ImM5N2Y1ZmYxLTBjZWYtNDdjOS1iZjBlLWU4YWU4NzdjYTk4ZiJ9.O49n56mID96cu2vY2ig-6AIL1NuL6lIYDcaO41g0LLA";
        TypePoint type = TypePoint.path;
        String name = point.name;
        String descricao = point.description;
        return AlertDialog(
            title: Text("Adicionar ponto ${point.id}"),
            content: Column(
              children: [
                Text("X = ${point.x}\nY = ${point.y}"),
                DropdownButtonFormField(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                      child: Text("Objetivo"),
                      value: TypePoint.goal,
                    ),
                    DropdownMenuItem(
                      child: Text("Caminho"),
                      value: TypePoint.path,
                    ),
                  ],
                  onChanged: (value) {
                    if (value != TypePoint.goal) {
                      name = "Caminho";
                      type = TypePoint.path;
                    } else {
                      name = "Objetivo";
                      type = TypePoint.goal;
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
                      name = "Ponto ${point.id}";
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
                onPressed: () {
                  point.name = name;
                  point.description = descricao;
                  PointRepository().editPoint(token, point);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Salvar",
                  style: TextStyle(color: Colors.green),
                ),
              )
            ]);
      });
}
