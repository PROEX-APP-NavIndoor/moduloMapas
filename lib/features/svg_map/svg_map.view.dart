import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';
import 'package:mvp_proex/features/point/point_child.model.dart';
import 'package:mvp_proex/features/point/point_parent.model.dart';
import 'package:mvp_proex/features/svg_map/svg_map_flags.dart';
import 'package:mvp_proex/features/widgets/dialog_view_point.dart';
import 'package:mvp_proex/features/widgets/shared/snackbar.message.dart';
import 'package:mvp_proex/features/widgets/painters.widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mvp_proex/features/user/user.model.dart';
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:mvp_proex/features/point/point.widget.dart';
import 'package:mvp_proex/features/point/point.repository.dart';
import 'package:mvp_proex/features/widgets/point_valid.widget.dart';
import 'package:mvp_proex/features/widgets/custom_appbar.widget.dart';
import 'package:mvp_proex/features/widgets/dialog_add_point.widget.dart';
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

  /// É o id do mapa que contém os pontos
  final String? mapID;

  /// O nome do mapa para ser passado para a CustomAppBar
  final String? mapName;

  const SVGMap({
    Key? key,
    required this.svgPath,
    required this.svgWidth,
    required this.svgHeight,
    this.mapID,
    this.mapName,
    this.svgScale = 1,
  }) : super(key: key);

  @override
  State<SVGMap> createState() => _SVGMapState();
}

class _SVGMapState extends State<SVGMap> {
  bool isAdmin = false;

  double? x, y;
  double top = 0, left = 0;

  late double scaleFactor;

  bool flagScale = true;
  bool flagDuration = false;

  late final Widget svg;

  // Mantido aqui apenas para saber de forma mais rápida, mas remover
  // TODO: remover quando não for mais necessário
  final String reitoriaId = "7aae38c8-1ac5-4c52-bd5d-648a8625209d";
  final String blocoCSuperiorId = "c5e47fab-0a29-4d79-be62-ae3320629dbd";
  final String blocoCTerreoId = "eb562369-e529-45e5-a353-2e353e591add";

  late PointParent pontoAnterior;
  List<PointModel> newPointList = [];

  final PdfInvoiceService service = PdfInvoiceService();

  void centralizar(bool flagScale) {
    setState(() {
      flagDuration = flagScale;
      top = ((pontoAnterior.y - MediaQuery.of(context).size.height / 2) +
              2 * AppBar().preferredSize.height) *
          -1;
      left = (pontoAnterior.x - MediaQuery.of(context).size.width / 2) * -1;
    });
  }

  late UserModel userModel;
  late PointParent pontoRecebido;
  String erroMessage = "ERRO INESPERADO";
  String erroDetalhe = "ERRO INESPERADO";

  StreamController<String> _streamcontroller = StreamController<String>();
  Future fetchMapPoints() async {
    _streamcontroller = StreamController<String>(
      onPause: () => debugPrint('Paused'),
      onResume: () => debugPrint('Resumed'),
      onCancel: () => debugPrint('Cancelled'),
      onListen: () async {
        SharedPreferences prefs;
        prefs = await SharedPreferences.getInstance();
        prefs.setString("token", userModel.token);
        try {
          await PointRepository()
              .getMapPoints(widget.mapID ?? blocoCSuperiorId)
              .then(
                (res) => {
                  if (res is! List)
                    {
                      debugPrint(
                          "ERRO na resposta de getMapPoint.\nO retorno deve ser uma lista de pontos\nTipo esperado: List, tipo recebido: " +
                              res.runtimeType.toString()),
                      erroMessage = "Erro no servidor.",
                      erroDetalhe = "Tipo inesperado.",
                      _streamcontroller.addError(erroMessage),
                    }
                  else
                    {
                      if (res.isEmpty)
                        {
                          if (userModel.permission != "super")
                            {
                              erroMessage = "Não há pontos no mapa.",
                              erroDetalhe =
                                  "Peça à um administrador para adicionar o ponto inicial do mapa.",
                              _streamcontroller.addError(erroMessage),
                            }
                          else
                            {
                              // Informar que deve inserir o ponto inicial
                            },
                        }
                      else
                        {
                          for (var ponto in res)
                            {
                              pontoRecebido = PointParent.fromJson(ponto),
                              newPointList.add(pontoRecebido),
                              if (pontoRecebido.children.isNotEmpty)
                                {
                                  for (PointChild filho
                                      in pontoRecebido.children)
                                    {
                                      newPointList.add(filho),
                                    }
                                }
                            },
                          prefs.setString(
                            "pontoAnterior",
                            pointModelToJson(newPointList.first),
                          ),
                          SvgMapFlags.modoAdicao = "caminho",
                          // O primeiro elemento da lista não pode ser um ponto filho
                          pontoAnterior = newPointList.first as PointParent,
                          centralizar(flagScale),
                          _streamcontroller.sink.add("1"),
                          _streamcontroller.close(),
                        },
                    },
                },
              );
        } on DioError catch (e) {
          if (kDebugMode) {
            print(e.response?.data);
          }
          if (e.response != null) {
            switch (e.response!.statusCode) {
              case 400:
                erroMessage = "[400] Bad Request";
                erroDetalhe = "Verifique a requisição";
                break;
              case 401:
                erroMessage = "[401] Não autorizado";
                erroDetalhe = "O usuário não possui autorização";
                break;
              case 404:
                erroMessage = "[404] Não encontrado";
                erroDetalhe =
                    e.response!.data["message"] ?? e.response!.statusMessage;
                break;
              default:
                erroMessage = "Erro desconhecido (" +
                    e.response!.statusCode.toString() +
                    ") - contate o suporte";
                if (e.response!.data is! String) {
                  erroDetalhe = e.response!.data["message"];
                } else {
                  erroDetalhe = e.response!.data!;
                }
                break;
            }
          } else {
            erroMessage = "Erro desconhecido";
            erroDetalhe = "Não houve resposta do servidor";
          }
          _streamcontroller.addError(erroMessage);
        }
      },
    );
    _streamcontroller.add("1");
  }

  @override
  void dispose() {
    _streamcontroller.close();
    super.dispose();
  }

  @override
  void initState() {
    userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.token == "") {
      Navigator.pushReplacementNamed(context, '/login');
    }
    fetchMapPoints();

    scaleFactor = widget.svgScale;
    svg = SvgPicture.asset(
      widget.svgPath,
      color: Colors.white,
      fit: BoxFit.none,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: _streamcontroller.stream,
      builder: (context, snapshot) {
        Widget childVar;
        if (snapshot.hasError) {
          childVar = Scaffold(
            body: AlertDialog(
              title: const Text("Erro de conexão"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                        "Ocorreu um erro ao se conectar com o servidor:\n"),
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
                      Navigator.pushReplacementNamed(context, '/mapselection');
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
          childVar = Center(
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

          childVar = Scaffold(
            appBar: CustomAppBar(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.home_work,
                        size: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        widget.mapName?? "Bloco C",
                        style: const TextStyle(
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
                  Positioned(
                    top: -10,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 35,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/mapselection');
                      },
                    ),
                  )
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
                                top = top + details.delta.dy;
                                left = left + details.delta.dx;
                              },
                            );
                          },
                          // Adiciona um ponto.
                          // Se não estiver no modo caminho não precisa validar se está na linha
                          // No final da adição, se houve adição de ponto ele é colocado na lista; se era adição de ponto filho ele automaticamente volta para adição de caminho
                          onTapDown: (details) {
                            if (isAdmin &&
                                SvgMapFlags.modoAdicao != "vizinho" &&
                                ((isValid && SvgMapFlags.isLine) ||
                                    (SvgMapFlags.modoAdicao != "caminho"))) {
                              dialogAddPoint(context, details).then((point) {
                                if (point != null) {
                                  newPointList.add(point);
                                  for (var element in newPointList) {
                                    if (element.uuid == pontoAnterior.uuid &&
                                        element is PointParent) {
                                      if (point is PointChild) {
                                        element.children.add(point);
                                      } else {
                                        // O pontoAnterior.neighbor é editado em dialog_add_point utilizando o que estava no prefs, mas ele só é atualizado na newPointList aqui
                                        for (var vizinho in point.neighbor) {
                                          if (vizinho["id"] == element.uuid) {
                                            String direction =
                                                vizinho["direction"];
                                            String directionAnterior = "";
                                            switch (direction) {
                                              case "N":
                                                directionAnterior = "S";
                                                break;
                                              case "S":
                                                directionAnterior = "N";
                                                break;
                                              case "E":
                                                directionAnterior = "W";
                                                break;
                                              case "W":
                                                directionAnterior = "E";
                                                break;
                                              default:
                                                break;
                                            }
                                            element.neighbor.add({
                                              "id": point.uuid,
                                              "direction": directionAnterior,
                                            });
                                          }
                                        }
                                        pontoAnterior =
                                            newPointList.last as PointParent;
                                      }
                                    }
                                  }
                                }
                                setState(() {
                                  newPointList = newPointList;
                                });
                              }).whenComplete(() {
                                if (SvgMapFlags.modoAdicao == "filho") {
                                  SvgMapFlags.modoAdicao = "caminho";
                                  setState(() {});
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
                                  CustomPaint(
                                    painter:
                                        PathPainter(pointList: newPointList),
                                    child: SizedBox(
                                      width: x,
                                      height: y,
                                    ),
                                  ),
                                if (SvgMapFlags.modoAdicao == "filho")
                                  CustomPaint(
                                    painter: LinePainter(
                                      coordInicialX: pontoAnterior.x,
                                      coordInicialY: pontoAnterior.y,
                                    ),
                                    child: SizedBox(
                                      width: x,
                                      height: y,
                                    ),
                                  ),
                                if (isAdmin)
                                  ...newPointList
                                      .map<Widget>(
                                        (pointInList) => PointWidget(
                                          point: pointInList,
                                          side: 5,
                                          idPontoAnterior: pontoAnterior.uuid,
                                          onPressed: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            if (SvgMapFlags.modoAdicao ==
                                                "vizinho") {
                                              if (pointInList is PointParent) {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Adicionar Vizinho?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              SvgMapFlags
                                                                      .modoAdicao =
                                                                  "caminho";
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "Cancelar",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              String direction;
                                                              String
                                                                  directionAnterior;
                                                              if (isValidX) {
                                                                if (pontoAnterior
                                                                        .y <
                                                                    pointInList
                                                                        .y) {
                                                                  direction =
                                                                      "N";
                                                                  directionAnterior =
                                                                      "S";
                                                                } else {
                                                                  direction =
                                                                      "S";
                                                                  directionAnterior =
                                                                      "N";
                                                                }
                                                              } else {
                                                                if (pontoAnterior
                                                                        .x <
                                                                    pointInList
                                                                        .x) {
                                                                  direction =
                                                                      "W";
                                                                  directionAnterior =
                                                                      "E";
                                                                } else {
                                                                  direction =
                                                                      "E";
                                                                  directionAnterior =
                                                                      "W";
                                                                }
                                                              }
                                                              if (isValidX ||
                                                                  isValidY) {
                                                                // Se ainda não for vizinho do ponto anterior (o amarelo)
                                                                if (pontoAnterior
                                                                        .neighbor
                                                                        .any((element) =>
                                                                            element["id"] ==
                                                                            pointInList.uuid) ==
                                                                    false) {
                                                                  // Adiciona o vizinho no ponto anterior (o amarelo)
                                                                  pontoAnterior
                                                                      .neighbor
                                                                      .add({
                                                                    "id": pointInList
                                                                        .uuid,
                                                                    "direction":
                                                                        directionAnterior,
                                                                  });
                                                                }
                                                                // Se ainda não for vizinho no ponto clicado
                                                                if (pointInList.neighbor.any((element) =>
                                                                        element[
                                                                            "id"] ==
                                                                        pontoAnterior
                                                                            .uuid) ==
                                                                    false) {
                                                                  // adiciona o vizinho no ponto clicado
                                                                  pointInList
                                                                      .neighbor
                                                                      .add({
                                                                    "id": pontoAnterior
                                                                        .uuid,
                                                                    "direction":
                                                                        direction,
                                                                  });
                                                                }
                                                                try {
                                                                  await PointRepository()
                                                                      .editPoint(
                                                                    pontoAnterior,
                                                                  );
                                                                  await PointRepository()
                                                                      .editPoint(
                                                                          pointInList);
                                                                  for (var element
                                                                      in newPointList) {
                                                                    if (element
                                                                            .uuid ==
                                                                        pontoAnterior
                                                                            .uuid) {
                                                                      if (element
                                                                          is PointParent) {
                                                                        element
                                                                            .neighbor
                                                                            .add({
                                                                          "id":
                                                                              pointInList.uuid,
                                                                          "direction":
                                                                              directionAnterior
                                                                        });
                                                                      }
                                                                    }
                                                                  }
                                                                  showMessageSucess(
                                                                    context:
                                                                        context,
                                                                    text:
                                                                        "Vizinho adicionado",
                                                                  );
                                                                } on DioError {
                                                                  pontoAnterior
                                                                      .neighbor
                                                                      .removeWhere(
                                                                    (e) =>
                                                                        e["id"] ==
                                                                        pointInList
                                                                            .uuid,
                                                                  );
                                                                  pointInList
                                                                      .neighbor
                                                                      .removeWhere(
                                                                    (e) =>
                                                                        e["id"] ==
                                                                        pontoAnterior
                                                                            .uuid,
                                                                  );
                                                                  showMessageError(
                                                                    context:
                                                                        context,
                                                                    text:
                                                                        "Erro ao adicionar vizinho",
                                                                  );
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                                SvgMapFlags
                                                                        .modoAdicao =
                                                                    "caminho";
                                                              }
                                                            },
                                                            child: const Text(
                                                                "Sim"),
                                                          )
                                                        ],
                                                      );
                                                    });
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "O ponto não pode ser objetivo nem obstáculo!",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              dialogViewPoint(
                                                context,
                                                pointInList,
                                                newPointList,
                                              ).whenComplete(() async {
                                                setState(() {
                                                  pontoAnterior =
                                                      pointParentFromJson(
                                                          prefs.getString(
                                                                  "pontoAnterior") ??
                                                              "");
                                                });
                                              });
                                            }
                                          },
                                        ),
                                      )
                                      .toList(),
                                if (isAdmin && SvgMapFlags.isLine)
                                  ...pointValidWidget(
                                    x: x ?? 0,
                                    y: y ?? 0,
                                    width: widget.svgWidth,
                                    height: widget.svgHeight,
                                    isValidX: isValidX,
                                    isValidY: isValidY,
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
                (isAdmin &&
                        (SvgMapFlags.modoAdicao == "caminho" ||
                            SvgMapFlags.modoAdicao == "vizinho"))
                    ? FloatingActionButton(
                        heroTag: "btnLine",
                        onPressed: () {
                          setState(
                            () {
                              SvgMapFlags.isLine = !SvgMapFlags.isLine;
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
        return childVar;
      },
    );
  }
}
