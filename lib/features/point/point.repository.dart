import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvp_proex/app/app.repository.dart';

class PointRepository extends AppRepository {
  Future getAllPoints(String token) async {
    const String erroMessage = "Erro na consulta";
    try {
      if (kDebugMode) {
        print("Get all points...");
      }
      return await dio
          .get(
        AppRepository.path + AppRepository.queryPoints,
        options: Options(headers: {"Authorization": "Bearer $token"}, responseType: ResponseType.plain),
      )
          .then(
        (res) {
          // print(res);
          // print(res.toString());
          // print("Resposta acima");
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }
}
