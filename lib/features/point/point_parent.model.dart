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
/// exemplo.type = TypePoint.initial;
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
  List<Map<String, dynamic>> neighbor = [{}];
  List<PointChild> children = [];
  TypePoint type = TypePoint.common;

  // generative constructor (no formal parameters)
  // calls the zero parameter super constructor
  PointParent({
    this.type = TypePoint.common,
    required this.neighbor,
    this.children = const [],
  });

  // named constructor
  /// Constrói um PointParent dado um json no tipo Map
  PointParent.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    for (var element in json["neighbor"]) {
      neighbor.add(element as Map<String, dynamic>);
    }
    if (json["type"] != null) {
      json["type"] == "initial"
          ? type = TypePoint.initial
          : json["type"] == "intermediary"
              ? type = TypePoint.intermediary
              : type = TypePoint.common;
    } else {
      type = TypePoint.common;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> parentData = {
      "neighbor": neighbor,
      "type": type.name,
      "children": children,
    };
    Map<String, dynamic> returnVal = super.toJson();
    returnVal.addEntries(parentData.entries);
    return returnVal;
  }
}
