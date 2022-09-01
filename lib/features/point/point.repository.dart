import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvp_proex/app/app.repository.dart';
import 'package:mvp_proex/features/point/point.model.dart';

class PointRepository extends AppRepository {
  // pega todos os pontos do banco
  Future getAllPoints(String token) async {
    const String erroMessage = "Erro na consulta";
    try {
      if (kDebugMode) {
        print("Get all points...");
      }
      return await dio
          .get(
        AppRepository.path + AppRepository.queryPoints,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
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

  // salva um ponto
  Future postPoint(String token, PointModel point) async {
    const String erroMessage = "Erro na consulta";
    try {
      if (kDebugMode) {
        print("Post point...");
      }
      return await dio
          .post(
        AppRepository.path + AppRepository.queryPoints,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
        data: point.toJson(),
      )
          .then((res) {
        return res.toString();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return erroMessage;
    }
  }

  // pega todos os pontos de um mapa

  Future getMapPoints(String token, String mapID) async {
    const String erroMessage = "Erro na consulta";
    try {
      if (kDebugMode) {
        print("Get map points...");
      }
      return await dio
          .get(
        AppRepository.path + AppRepository.queryMap + "/" + mapID,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
      )
          .then(
        (res) {
          return res.data.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }

  Future editPoint(String token, PointModel point) async {
    const String erroMessage = "Erro na consulta";
    try {
      if (kDebugMode) {
        print("Edit point...");
      }
      return await dio
          .put(
        AppRepository.path + AppRepository.queryPoints + "/" + point.uuid,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
        data: point.toJson(),
      )
          .then(
        (res) {
          print(res.toString());
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }

  Future deletePoint(String token, String pointId) async {
    const String erroMessage = "Erro na consulta";
    try {
      if (kDebugMode) {
        print("Delete point...");
      }
      return await dio
          .delete(
        AppRepository.path + AppRepository.queryPoints + "/" + pointId,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
      )
          .then(
        (res) {
          print(res.toString());
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }
}
