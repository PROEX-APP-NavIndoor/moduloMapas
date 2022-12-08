import 'package:flutter/material.dart';
import 'package:mvp_proex/features/svg_map/svg_map.view.dart';

class MapView extends StatefulWidget {
  final String? mysvgPath;
  final String? mapId;
  final String? mapName;
  const MapView({
    Key? key,
    this.mysvgPath,
    this.mapId,
    this.mapName,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SVGMap(
          svgPath: widget.mysvgPath ?? "assets/maps/c1/c1PavimentoSuperior.svg",
          svgWidth: 800,
          svgHeight: 600,
          svgScale: 1.3,
          mapID: widget.mapId,
          mapName: widget.mapName,
        ),
      ),
    );
  }
}
