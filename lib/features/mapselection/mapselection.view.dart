import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mvp_proex/app/app.color.dart';
import 'package:mvp_proex/features/map/map.view.dart';
import 'package:mvp_proex/features/mapselection/mapselection.repository.dart';
import 'package:mvp_proex/features/user/user.model.dart';
import 'package:mvp_proex/features/user/user.repository.dart';
import 'package:provider/provider.dart';

class MapselectionView extends StatefulWidget {
  const MapselectionView({Key? key}) : super(key: key);

  @override
  State<MapselectionView> createState() => _MapselectionViewState();
}

class _MapselectionViewState extends State<MapselectionView> {
  late UserModel userModel;
  Repository repository = Repository();
  final _formKey = GlobalKey<FormState>();

  StreamController<String> _streamController = StreamController<String>();
  List listOfMaps = [];
  void getAllMaps() {
    _streamController = StreamController<String>(onListen: () async {
      try {
        listOfMaps = await MapselectionRepository().getMapList(
          token: userModel.token,
        );
        _streamController.sink.add("event");
        _streamController.close();
      } on DioError catch (e) {
        switch (e.response!.statusCode) {
          case 404:
            print("Not found");
            break;
          case 401:
            print("Unauthorized");
            break;
          default:
            break;
        }
        _streamController.addError("error");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.token == "") {
      Navigator.of(context).pushReplacementNamed('/login');
    }
    getAllMaps();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Map<String, dynamic> mapa = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Text("Ocorreu um erro"),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
            body: Center(
          child: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Selecione o mapa a ser visualizado:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    DropdownButtonFormField(
                      dropdownColor: Color.fromARGB(
                          AppColors.primary.alpha,
                          AppColors.primary.red ~/ 2,
                          AppColors.primary.green ~/ 2,
                          AppColors.primary.blue ~/ 2),
                      items: listOfMaps
                          .map((e) => DropdownMenuItem(
                                child: Text(
                                  e["name"] ?? "ERR",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                value: e,
                              ))
                          .toList(),
                      value: listOfMaps[0],
                      onChanged: (value) => {
                        mapa = value as Map<String, dynamic>,
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MapView(mysvgPath: mapa["source"], mapId: mapa["id"],)));
                        },
                        child: const Text("Acessar mapa")),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }
}
