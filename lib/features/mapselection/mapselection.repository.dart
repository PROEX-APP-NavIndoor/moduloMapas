import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvp_proex/app/app.repository.dart';

class MapselectionRepository extends AppRepository {
  Future<List> getMapList({required String token}) async {
    if (kDebugMode) {
      print("Get maps...");
    }
    try {
      return await dio
          .get(
        AppRepository.path + AppRepository.queryMap,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
          responseType: ResponseType.json,
        ),
      )
          .then((res) {
        return res.data;
      });
    } on DioError {
      rethrow;
    }
  }
}
