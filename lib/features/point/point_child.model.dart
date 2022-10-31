import 'package:mvp_proex/features/point/point.model.dart';

/// Cria um objeto ponto filho, que herda do objeto ponto.
/// ```dart
/// var exemplo = PointChild();
/// exemplo.x = 10.0;
/// exemplo.isObstacle = false;
///
/// var novoexemplo = PointChild.fromJson(json);
/// // json (ou subjson) deve ser:
/// {
/// id: "string",
/// x: 0.0,
/// // ... y, name, description, floor, mapId,
/// parentId: "string"
/// isObstacle: false
/// }
/// ```
class PointChild extends PointModel {
  String parentId = "";
  bool isObstacle = false;

  PointChild({
    this.parentId = "",
    this.isObstacle = false,
  });

  PointChild.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    parentId = json["parentId"];
    isObstacle = json["isObstacle"];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> childData = {
      "parentId": parentId,
      "isObstacle": isObstacle
    };
    Map<String, dynamic> returnVal = super.toJson();
    returnVal.addEntries(childData.entries);
    return returnVal;
  }
}
