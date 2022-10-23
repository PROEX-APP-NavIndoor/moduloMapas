import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/login/login.repository.dart';
import 'package:mvp_proex/features/user/user.model.dart';
import 'package:mvp_proex/features/person/person.model.dart';
import 'package:mvp_proex/features/person/person.widget.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point.widget.dart';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/widgets/point_valid.widget.dart';
import 'package:mvp_proex/features/widgets/custom_appbar.widget.dart';
import 'package:mvp_proex/features/widgets/dialog_edit_point.dart';
import 'package:mvp_proex/features/widgets/dialog_point.widget.dart';
import 'package:mvp_proex/invoice_service.dart';
import 'package:dio/dio.dart';

class SVGMap extends StatefulWidget {
  /// Define o caminho do asset:
  ///
  /// ```dart
  /// SVGMap(
  ///   svgPath: "assets/maps/c1/c1PavimentoTerreo.svg",
  ///   ...
  /// ),
  /// ```
  final String svgPath;

  /// Define a largura do SVG, em pixel
  ///
  /// ```dart
  /// SVGMap(
  ///   ...
  ///   svgWidth: 800,
  ///   ...
  /// ),
  /// ```
  final double svgWidth;

  /// Define a altura do SVG, em pixel
  ///
  /// ```dart
  /// SVGMap(
  ///   ...
  ///   svgHeight: 600,
  ///   ...
  /// ),
  /// ```
  final double svgHeight;

  /// Define a scala inicial do SVG, em pixel
  /// Por padrão ele é 1.0
  ///
  /// ```dart
  /// SVGMap(
  ///   ...
  ///   svgScale: 1.1,
  ///   ...
  /// ),
  /// ```
  final double svgScale;

  /// Define a origem o personagem no SVG
  /// Por padrão ele é 0
  ///
  /// ```dart
  /// SVGMap(
  ///   ...
  ///   person: person,
  ///   ...
  /// ),
  /// ```
  final PersonModel person;

  const SVGMap({
    Key? key,
    required this.svgPath,
    required this.svgWidth,
    required this.svgHeight,
    this.svgScale = 1,
    required this.person,
  }) : super(key: key);

  @override
  State<SVGMap> createState() => _SVGMapState();
}

class _SVGMapState extends State<SVGMap> {
  bool isAdmin = false;
  bool isLine = true;

  double? top, x;
  double? left, y;

  late double scaleFactor;

  bool flagScale = true;
  bool flagDuration = false;

  late final Widget svg;

  late double objetivoX;
  late double objetivoY;

  //só enquanto tivermos apenas esse mapa, depois que tiver uma tela pra escolher o mapa teremos que mudar
  late String reitoriaId = "7aae38c8-1ac5-4c52-bd5d-648a8625209d";
  late String blocoC11Id = "c5e47fab-0a29-4d79-be62-ae3320629dbd";

  String prev = "";
  late PointModel pontoAnterior;
  int id = 0;
  int inicio = 0;
  List<PointModel> newPointList = [];
  Map graph = {};

  final PdfInvoiceService service = PdfInvoiceService();

  void centralizar(bool flagScale) {
    setState(() {
      flagDuration = flagScale;
      top = ((widget.person.y - MediaQuery.of(context).size.height / 2) +
              2 * AppBar().preferredSize.height) *
          -1;
      left = (widget.person.x - MediaQuery.of(context).size.width / 2) * -1;
    });
  }

  PointRepository allPoints = PointRepository();
  Future<String>? connected;
  SharedPreferences? prefs;
  String erroMessage = "ERRO INESPERADO";
  String erroDetalhe = "ERRO INESPERADO";

  // Realiza o login automaticamente para testes, na versão final tem que passar pela tela de login antes de entrar na tela de mapas
  String tempToken = "";
  UserModel tempModel =
      UserModel(email: "gabriel@gmail.com", password: "123456");
  LoginRepository tempLogin = LoginRepository();

  StreamController<String> _strcontroller = StreamController<String>();
  Future fetchMapPoints() async {
    _strcontroller = StreamController<String>(
      onPause: () => print('Paused'),
      onResume: () => print('Resumed'),
      onCancel: () => print('Cancelled'),
      onListen: () async {
        SharedPreferences prefs;
        try {
          await tempLogin.postToken(model: tempModel).then(
                (res) async => {
                  tempToken = res,
                  prefs = await SharedPreferences.getInstance(),
                  await allPoints.getMapPoints(tempToken, blocoC11Id).then(
                        (res) => {
                          for (var cada in res)
                            {
                              newPointList.add(PointModel.fromJson(cada)),
                            },
                          id = newPointList.length,
                          // TODO: tratar quando não houver pontos no mapa (quando id == 0)
                          prefs.setString(
                            "pontoAnterior",
                            pointModelToJson(newPointList.first),
                          ),
                          pontoAnterior = newPointList.first,
                        },
                      ),
                },
              );
          _strcontroller.sink.add("1");
          _strcontroller.close();
        } on DioError catch (e) {
          if (kDebugMode) {
            print(e.response?.data);
          }
          switch (e.response?.statusCode) {
            case 400:
              erroMessage = "[400] Credenciais incorretas";
              erroDetalhe = "Verifique o login";
              break;
            case 401:
              erroMessage = "[401] Não autorizado";
              erroDetalhe = "O usuário não possui autorização";
              break;
            case 404:
              erroMessage = "[404] Não encontrado";
              erroDetalhe = e.response!.data["message"];
              break;
            default:
              erroMessage = "Erro desconhecido (" +
                  e.response!.statusCode.toString() +
                  ") - contate o suporte";
              erroDetalhe = e.response?.data["message"];
              break;
          }
          _strcontroller.addError(erroMessage);
          // throw ("Erro de conexão");
        }
      },
    );
    _strcontroller.add("1");
  }

  @override
  void dispose() {
    _strcontroller.close();
    super.dispose();
  }

  @override
  void initState() {
    fetchMapPoints();

    scaleFactor = widget.svgScale;
    svg = SvgPicture.asset(
      widget.svgPath,
      color: Colors.white,
      fit: BoxFit.none,
    );
    graph[0] = {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (left == null && top == null) {
      top = ((widget.person.y - MediaQuery.of(context).size.height / 2) +
              AppBar().preferredSize.height) *
          -1;
      left = (widget.person.x - MediaQuery.of(context).size.width / 2) * -1;
    }
    return StreamBuilder<Object>(
      stream: _strcontroller.stream,
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasError) {
          child = Scaffold(
            body: AlertDialog(
              title: const Text("Erro de conexão"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                        "Ocorreu um erro ao se conectar com o servidor:"),
                    Text(
                      erroMessage,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(erroDetalhe),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      print("Voltar para página anterior");
                    },
                    child: const Text("Voltar")),
                TextButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print("Tentar conexão novamente..");
                      }
                      fetchMapPoints();
                      setState(() {});
                    },
                    child: const Text("Tentar novamente")),
              ],
            ),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          child = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Aguardando servidor...',
                    style: TextStyle(
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          bool isValidX = pontoAnterior.x > ((x ?? 1) - 1) &&
              pontoAnterior.x < ((x ?? 0) + 1);

          bool isValidY = pontoAnterior.y > ((y ?? 1)) - 1 &&
              pontoAnterior.y < ((y ?? 0) + 1);

          bool isValid = isValidX || isValidY;

          child = Scaffold(
            appBar: CustomAppBar(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.home_work,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Entrada Reitoria",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: -10,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.qr_code_outlined,
                        size: 35,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final data = await service.createPDF(newPointList);
                        service.savePdfFile("QR_Todos", data);
                      },
                    ),
                  ),
                ],
              ),
            ),
            body: Transform.rotate(
              angle: math.pi / 0.5,
              child: Transform.scale(
                scale: scaleFactor,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: flagDuration
                          ? const Duration(milliseconds: 500)
                          : const Duration(milliseconds: 0),
                      top: top,
                      left: left,
                      child: MouseRegion(
                        onHover: (event) {
                          if (isAdmin) {
                            setState(() {
                              x = event.localPosition.dx;
                              y = event.localPosition.dy;
                            });
                          }
                        },
                        child: GestureDetector(
                          onDoubleTap: () {
                            setState(
                              () {
                                if (flagScale) {
                                  scaleFactor *= 2;
                                  flagScale = false;
                                } else {
                                  scaleFactor *= 1 / 2;
                                  flagScale = true;
                                }
                              },
                            );
                          },
                          onPanUpdate: (details) {
                            setState(
                              () {
                                flagDuration = false;
                                top = top! + details.delta.dy;
                                left = left! + details.delta.dx;
                              },
                            );
                          },
                          onLongPressEnd: (details) {
                            setState(
                              () {
                                objetivoX = details.localPosition.dx;
                                objetivoY = details.localPosition.dy;

                                widget.person.setx = objetivoX;
                                widget.person.sety = objetivoY;
                              },
                            );
                          },
                          onTapDown: (details) {
                            if (isAdmin && isValid && isLine) {
                              SharedPreferences prefs;
                              dialogPointWidget(context, details, id,
                                      newPointList, graph, tempToken)
                                  .then((point) => {
                                        if (point != null)
                                          {
                                            newPointList.add(point),
                                            pontoAnterior = newPointList.last
                                          }
                                      });
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                svg,
                                if (isAdmin)
                                  ...newPointList
                                      .map<Widget>(
                                        (e) => PointWidget(
                                          point: e,
                                          side: 5,
                                          onPressed: () {
                                            if (isAdmin) {
                                              //somente desktop
                                              dialogEditPoint(
                                                      context,
                                                      e,
                                                      id,
                                                      tempToken,
                                                      inicio,
                                                      centralizar,
                                                      widget,
                                                      newPointList,
                                                      graph)
                                                  .whenComplete(
                                                () {
                                                  SharedPreferences
                                                          .getInstance()
                                                      .then(
                                                    (value) {
                                                      prefs = value;
                                                      setState(
                                                        () {
                                                          pontoAnterior =
                                                              pointModelFromJson(
                                                                  prefs?.getString(
                                                                          "pontoAnterior") ??
                                                                      "");
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      )
                                      .toList(),
                                PersonWidget(
                                  person: widget.person,
                                ),
                                if (isAdmin && isLine)
                                  ...pointValidWidget(
                                    x: x ?? 0,
                                    y: y ?? 0,
                                    width: widget.svgWidth,
                                    height: widget.svgHeight,
                                    isValidX: isValidX,
                                    isValidY: isValidY,
                                    lastPoint: pontoAnterior,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                isAdmin
                    ? FloatingActionButton(
                        heroTag: "btnLine",
                        onPressed: () {
                          setState(
                            () {
                              isLine = !isLine;
                            },
                          );
                        },
                        child: const Icon(
                          Icons.line_style,
                          size: 30,
                        ),
                      )
                    : Container(),
                isAdmin
                    ? const SizedBox(
                        height: 20,
                      )
                    : Container(),
                (kIsWeb ||
                        Platform.isLinux ||
                        Platform.isMacOS ||
                        Platform.isWindows)
                    ? FloatingActionButton(
                        heroTag: "btnAdmin",
                        backgroundColor: Colors.red[900],
                        onPressed: () {
                          setState(
                            () {
                              isAdmin = !isAdmin;
                              // criar scaffold message
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isAdmin
                                        ? 'Modo Admin Ativado'
                                        : 'Modo Admin Desativado',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                        ),
                      )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton(
                  heroTag: "btnScale",
                  onPressed: () {
                    setState(
                      () {
                        if (flagScale) {
                          scaleFactor *= 2;
                          flagScale = false;
                        } else {
                          scaleFactor *= 1 / 2;
                          flagScale = true;
                        }
                      },
                    );
                  },
                  child: Icon(
                    flagScale ? Icons.zoom_in_sharp : Icons.zoom_out_map,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton(
                  heroTag: "btnCentralizar",
                  onPressed: () {
                    centralizar(true);
                  },
                  child: const Icon(
                    Icons.center_focus_strong,
                    size: 30,
                  ),
                ),
              ],
            ),
          );
        }
        return child;
      },
    );
  }
}
