import 'dart:convert';

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
      this.neighbor = const {},
      this.mapId = ""}
      );

  String uuid;
  int id;
  String name;
  String description;
  double x;
  double y;
  int floor;
  bool breakPoint;
  Map<String, dynamic> neighbor;
  String mapId;

  factory PointModel.fromJson(Map<String, dynamic> json) => PointModel(
        uuid: json["id"],
        name: json["name"],
        description: json["description"],
        x: json["x"].toDouble(),
        y: json["y"].toDouble(),
        floor: json["floor"],
        breakPoint: json["breakPoint"],
        neighbor: json["neighbor"] ?? {},
        mapId: json["map_id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "floor": floor,
        "x": x,
        "y": y,
        "breakPoint": breakPoint,
        "neighbor": neighbor,
        "map_id": mapId,
      };
}