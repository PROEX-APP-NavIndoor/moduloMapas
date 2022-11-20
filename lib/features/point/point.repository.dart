import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvp_proex/app/app.constant.dart';
import 'package:mvp_proex/app/app.repository.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Classe utilizada para a comunicação com o banco referente às ações de ponto.
///
/// O token utilizado está sendo passado por SHARED PREFERENCES, caso seja necessário basta mudar aqui para PROVIDER.
class PointRepository extends AppRepository {
  /// Pega todos os pontos do banco.
  Future getAllPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
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
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }

  /// Salva um ponto no banco.
  Future postPoint(String pointClass, PointModel point) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    try {
      if (kDebugMode) {
        print("Post point...");
      }
      return await dio
          .post(
        AppRepository.path + AppRepository.queryPoints + "/" + pointClass,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
        data: point.toJson(), //TODO: arrumar o .toJson
      )
          .then((res) {
        return res.toString();
      });
    } on DioError {
      if (kDebugMode) {
        print("ERRO no post");
      }
      rethrow;
    }
  }

  /// Pega todos os pontos de um mapa.
  ///
  /// Retorna um vetor de pontos no tipo Map
  Future getMapPoints(String mapID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    try {
      if (kDebugMode) {
        print("Get map points...");
      }
      return await dio
          .get(
        AppRepository.path + AppRepository.queryMap + "/" + mapID,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.json),
      )
          .then(
        (res) {
          return (json.decode(res.toString())['points']);
        },
      );
    } on DioError {
      // Não é necessário catch, porque o erro que ocorrer aqui deve ser tratado no svg_map.view, então apenas repassa o erro para lá
      // Pode ser que seja melhor retornar uma string sobre o erro (ao invés do erro todo), e então apenas mostrar a mensagem, mas aí ocorreria um erro inesperado - não haveria nenhum throw aqui, o erro em si só aconteceria no svg_map ao tentar tratar a string da mensagem de erro de resposta como se fosse a lista de pontos esperada.
      // É melhor então tratar um erro que nós mesmos jogamos ou tratar qualquer erro inesperado indefinidamente?
      rethrow;
    }
  }

  /// Edita um ponto no banco.
  Future editPoint(PointModel point) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    try {
      if (kDebugMode) {
        print("Edit point...");
      }
      return await dio
          .put(
        AppRepository.path +
            AppRepository.queryPoints +
            "/" +
            (point is PointParent ? "parent" : "child") +
            "/" +
            point.uuid,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
        data: point.toJson(),
      )
          .then(
        (res) {
          // print(res.toString());
          return res.toString();
        },
      );
    } on DioError {
      if (kDebugMode) {
        print("ERRO em editPoint");
      }
      rethrow;
    }
  }

  /// Deleta um ponto no banco.
  ///
  /// [pointClass] é o tipo do ponto, necessário para a rota; **deve ser _parent_ ou _child_**.
  ///
  /// [pointId] é o id do ponto a ser deletado.
  Future deletePoint(String pointClass, String pointId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    try {
      if (kDebugMode) {
        print("Delete point...");
      }
      return await dio
          .delete(
        AppRepository.path +
            AppRepository.queryPoints +
            "/" +
            pointClass +
            "/" +
            pointId,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            responseType: ResponseType.plain),
      )
          .then(
        (res) {
          return res.toString();
        },
      );
    } on DioError {
      if (kDebugMode) {
        print("ERRO em deletePoint");
      }
      rethrow;
    }
  }
}
