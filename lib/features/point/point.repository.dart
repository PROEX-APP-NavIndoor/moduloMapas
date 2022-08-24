import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:mvp_proex/app/app.repository.dart';
import 'package:mvp_proex/features/point/point.model.dart';

class PointRepository extends AppRepository {
  Future getAllPoints(String token) async {
    const String erroMessage = "Erro na consulta";
    try {
      print("Get all points...");
      return await dio
          .get(
        AppRepository.path + AppRepository.queryPoints,
        options: Options(headers: {'Authorization': "Bearer $token"}),
      )
          .then(
        (res) {
          // print(res.data.toString());
          // print("Resposta acima");

          // print(json.decode(res.data));
          // print("Lista acima");
          json.decode(res.data);
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }
}
