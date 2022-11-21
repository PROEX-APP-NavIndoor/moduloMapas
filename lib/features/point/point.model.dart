import 'dart:convert';

PointModel pointModelFromJson(String str) =>
    PointModel.fromJson(json.decode(str));

String pointModelToJson(PointModel data) => json.encode(data.toJson());

class PointModel {
  String uuid="";
  String name="";
  String description="";
  double x=0.0;
  double y=0.0;
  int floor=0;
  String mapId="";

  PointModel(
      {this.uuid = "",
      this.name = "",
      this.description = "",
      this.x = 0.0,
      this.y = 0.0,
      this.floor = 1,
      this.mapId = ""});

  PointModel.fromJson(Map<String, dynamic> json) {
    uuid = json["id"] ?? "";
    name = json["name"];
    description = json["description"];
    x = json["x"].toDouble();
    y = json["y"].toDouble();
    floor = json["floor"];
    mapId = json["map_id"];
  }

  Map<String, dynamic> toJson() => {
        // se o uuid for vazio é porque acabou de criar, então não passa para o post
        if(uuid != "")
          "id": uuid,
        "name": name,
        "description": description,
        "floor": floor,
        "x": x,
        "y": y,
        "map_id": mapId,
      };
}
