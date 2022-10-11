import 'dart:convert';

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
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }

  // salva um ponto
  Future postPoint(String token, PointModel point) async {
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
    } on DioError {
      print("ERRO no post");
      rethrow;
    }
  }

  // pega todos os pontos de um mapa
  Future getMapPoints(String token, String mapID) async {
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

  // O json é recebido como string, mas quando dá decode, ele vira um mapa, então quando dá json.decode(res.toString()), temos um mapa onde a chave 'points' tem como valor um vetor de mapas. No PointModel.fromJson não se usa um tipo "Json" (isso não existe), se usa um mapa; portanto pegar só o ['points'] é exatamente o que precisa para transformar cada mapa dentro desse vetor em um PointModel

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
          // print(res.toString());
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
          return res.toString();
        },
      );
    } catch (e) {
      return erroMessage;
    }
  }
}
