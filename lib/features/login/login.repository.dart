import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvp_proex/app/app.repository.dart';

class LoginRepository extends AppRepository {
  final Dio dio = Dio();

  Future<String> postToken({required dynamic model}) async {
    const String erroMessage = "Erro na consulta";
    try {
      return await dio
          .post(
        AppRepository.path + AppRepository.queryLogin,
        data: model.toJson(),
      )
          .then(
        (res) {
          return res.data['token'] ?? erroMessage;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return erroMessage;
    }
  }
}
