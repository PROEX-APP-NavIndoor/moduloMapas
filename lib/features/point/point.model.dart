import 'package:mvp_proex/app/app.constant.dart';

class PointModel {
  late String uuid;
  late int id;
  late String name;
  late String description;
  late double x;
  late double y;
  late int floor;
  late bool breakpoint;
  late Map neighbor;
  // "{"left": {"id":"7e07052a-1ca4-4372-b4ce-b10acd55efeb", "peso":5}}"
  late TypePoint type;
  late String mapId;

  PointModel();

  factory PointModel.fromJson(Map<String, dynamic> json) {
    var retorno = PointModel();
    retorno.uuid = json["id"] ?? "";
    retorno.name = json["name"];
    retorno.description = json["description"];
    retorno.x = json["x"];
    retorno.y = json["y"];
    retorno.floor = json["floor"];
    retorno.breakpoint = json["breakPoint"];
    retorno.neighbor = json["neighbor"];
    retorno.mapId = json["map_id"];
    return retorno;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{}; // Map<String, dynamic>()
    json["id"] = uuid;
    json["name"] = name;
    json["description"] = description;
    json["x"] = x.toString();
    json["y"] = y.toString();
    json["floor"] = floor.toString();
    json["breakpoint"] = breakpoint.toString();
    json["neighbor"] = neighbor;
    json["map_id"] = mapId;
    return json;
  }
}
