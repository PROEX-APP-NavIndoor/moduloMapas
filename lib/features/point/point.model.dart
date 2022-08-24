// To parse this JSON data, do
//
//     final pointModel = pointModelFromJson(jsonString);

import 'dart:convert';

import 'package:mvp_proex/app/app.constant.dart';

PointModel pointModelFromJson(String str) =>
    PointModel.fromJson(json.decode(str));

String pointModelToJson(PointModel data) => json.encode(data.toJson());

class PointModel {
  PointModel(
      {this.uuid = "",
      this.id = 0,
      this.name = "",
      this.description = "",
      this.x = 0.0,
      this.y = 0.0,
      this.floor = 1,
      this.breakPoint = false,
      this.neighbor = "",
      this.mapId = "",
      this.type = TypePoint.path});

  String uuid;
  int id;
  String name;
  String description;
  double x;
  double y;
  int floor;
  bool breakPoint;
  String neighbor;
  String mapId;
  TypePoint type;

  factory PointModel.fromJson(Map<String, dynamic> json) => PointModel(
        uuid: json["id"],
        name: json["name"],
        description: json["description"],
        x: json["x"],
        y: json["y"],
        floor: json["floor"],
        breakPoint: json["breakPoint"],
        neighbor: json["neighbor"],
        mapId: json["map_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": uuid,
        "name": name,
        "description": description,
        "x": x,
        "y": y,
        "floor": floor,
        "breakPoint": breakPoint,
        "neighbor": neighbor,
        "map_id": mapId,
      };
}
