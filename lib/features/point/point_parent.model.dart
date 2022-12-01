import 'package:mvp_proex/app/app.constant.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'dart:convert';

/// Retorna um PointParent dado um json no tipo String
PointParent pointParentFromJson(String str) =>
    PointParent.fromJson(json.decode(str));

/// Cria um objeto ponto pai, que herda do objeto ponto.
/// ```dart
/// var exemplo = PointParent();
/// exemplo.x = 10.0;
/// exemplo.type = TypePoint.entrance;
///
/// var novoexemplo = PointParent.fromJson(json);
/// // json deve ser:
/// {
/// id: "string",
/// x: 0.0,
/// // ... y, name, description, floor, mapId,
/// neighbors: [{
///   id: "string"
///   direction: "string"
/// }],
/// children: [{PointChild.toJson()}], // As childrens devem ser objetos completos em formato json
/// type: "initial"
/// }
/// ```
class PointParent extends PointModel {
  // fields
  List<Map<String, dynamic>> neighbor = [];
  List<PointChild> children = [];
  TypePoint type = TypePoint.common;

  // generative constructor (no formal parameters)
  // calls the zero parameter super constructor
  PointParent() {
    type = TypePoint.common;
    neighbor = [];
    children = [];
  }

  // named constructor
  /// Constrói um PointParent dado um json no tipo Map
  PointParent.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json["type"] != null) {
      json["type"] == "entrance"
          ? type = TypePoint.entrance
          : json["type"] == "passage"
              ? type = TypePoint.passage
              : type = TypePoint.common;
    } else {
      type = TypePoint.common;
    }
    if (json["neighbor"] != null) {
      for (var element in json["neighbor"]) {
        neighbor.add(element as Map<String, dynamic>);
      }
    }
    if (json["children"] != null) {
      for (var element in json["children"]) {
        children.add(PointChild.fromJson(element));
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> pointChildList = [];
    for (PointChild element in children) {
      pointChildList.add(element.toJson());
    }

    final Map<String, dynamic> parentData = {
      "neighbor": neighbor,
      "type": type.name,
      "children": pointChildList,
    };

    Map<String, dynamic> returnVal = super.toJson();
    returnVal.addEntries(parentData.entries);
    
    return returnVal;
  }
}
