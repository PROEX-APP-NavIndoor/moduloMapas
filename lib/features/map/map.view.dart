import 'package:flutter/material.dart';
import 'package:mvp_proex/features/svg_map/svg_map.view.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Reitoria xy: 639 274

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SVGMap(
          svgPath: "assets/maps/c1/c1PavimentoSuperior.svg", // TODO: pegar o path do mapa pelo servidor
          svgWidth: 800,
          svgHeight: 600,
          svgScale: 1.3,
        ),
      ),
    );
  }
}
