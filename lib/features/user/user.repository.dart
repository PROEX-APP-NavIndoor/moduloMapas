import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvp_proex/app/app.repository.dart';
import 'package:mvp_proex/features/user/user.model.dart';

class UserRepository extends AppRepository {
  Future<String> login({required UserModel userModel}) async {
    try {
      if (kDebugMode) {
        print("Login...");
      }
      return await dio
          .post(
        AppRepository.path + AppRepository.queryLogin,
        data: userModel.toJson(),
      )
          .then(
        (res) {
          return res.data["token"] ?? "";
        },
      );
    } on DioError catch (e) {
      if (e.response != null) {
        return "Erro " +
            e.response!.statusCode.toString() +
            ": " +
            e.response!.statusMessage!;
      }
      return jsonEncode({
        "code": 5000,
        "message": "Erro Interno",
        "details": e.response.toString(),
      });
    }
  }

  Future<Map> getUser(String token) async {
    try {
      if (kDebugMode) {
        print("Get user...");
      }
      return await dio
          .get(
        AppRepository.path + AppRepository.queryUser,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          responseType: ResponseType.json,
        ),
      )
          .then(
        (Response res) {
          return res.data;
        },
      );
    } on DioError catch (e) {
      if (e.response != null) {
        return {
          "code": e.response!.statusCode,
          "message": e.response!.statusMessage
        };
      }
      return {"code": 5000, "message": "Internal Error. No response."};
    }
  }

  Future<String> getAllUsers() async {
    try {
      return await dio
          .post(
        AppRepository.path + AppRepository.queryAllUsers,
      )
          .then(
        (value) {
          if (value.statusCode == 200) {
            return jsonEncode(value.data);
          }
          return jsonEncode(value.data);
        },
      );
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          return jsonEncode({"code": 404, "message": "API Offline"});
        }

        return jsonEncode(e.response);
      }
      return jsonEncode(e.response);
    } catch (e) {
      return jsonEncode({"code": 5000, "message": "Error Interno"});
    }
  }

  Future<String> editAccount(UserModel userModel) async {
    try {
      return await dio
          .post(
        AppRepository.path + AppRepository.queryLogin,
        data: userModel.toJson(),
      )
          .then(
        (value) {
          if (value.statusCode == 200) {
            return jsonEncode(value.data);
          }
          return jsonEncode(value.data);
        },
      );
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          return jsonEncode({"code": 404, "message": "API Offline"});
        }

        return jsonEncode(e.response);
      }
      return jsonEncode(e.response);
    } catch (e) {
      return jsonEncode({"code": 5000, "message": "Error Interno"});
    }
  }

  Future<String> deleteAccount(String uid) async {
    try {
      return await dio
          .delete(
        AppRepository.path + AppRepository.queryUser + "/" + uid,
      )
          .then(
        (value) {
          if (value.statusCode == 200) {
            return jsonEncode(value.data);
          }
          return jsonEncode(value.data);
        },
      );
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          return jsonEncode({"code": 404, "message": "API Offline"});
        }

        return jsonEncode(e.response);
      }
      return jsonEncode(e.response);
    } catch (e) {
      return jsonEncode({"code": 5000, "message": "Error Interno"});
    }
  }
}
