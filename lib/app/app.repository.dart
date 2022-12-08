import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppRepository {
  static const String path = 'https://api-proex.onrender.com';
  static const String queryLogin = '/login';
  static const String queryUser = '/user';
  static const String queryAllUsers = '/users';
  static const String queryMap = '/maps';
  static const String queryBuilder = '/api/accounts';
  static const String queryOrganization = '/api/accounts';
  static const String queryPoints = '/points';

  Dio dio = Dio();

  Future<String> post(
      {required dynamic model, required String query, Options? options}) async {
    const String erroMessage = "Erro na consulta";
    //print(model.toJson());
    try {
      return await dio
          .post(
        AppRepository.path + query,
        data: model.toJson(),
        options: options,
      )
          .then(
        (res) {
          return res.data.toString();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erro em post:\n");
        print(e);
      }
      return erroMessage;
    }
  }

  Future<String> get(
      {required String id, required String query, Options? options}) async {
    const String erroMessage = "Erro na consulta";
    if (kDebugMode) {
      print("GET...\n");
      print(AppRepository.path + query + '/' + id);
    }
    try {
      return await dio
          .get(
        AppRepository.path + query + '/' + id,
        options: options,
      )
          .then(
        (res) {
          return res.data["id"] == null
              ? res.data.toString()
              : jsonEncode(res.data);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erro em post:\n");
        print(e);
      }
      return erroMessage;
    }
  }
}
