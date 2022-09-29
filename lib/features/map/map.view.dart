import 'package:flutter/material.dart';
import 'package:mvp_proex/features/person/person.model.dart';
import 'package:mvp_proex/features/svg_map/svg_map.view.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  PersonModel person = PersonModel(234, 300, 0, -22.2467586, -45.0171148, 0);
  // Reitoria xy: 639 274

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SVGMap(
          svgPath: "assets/maps/c1/c1PavimentoSuperior.svg",
          svgWidth: 800,
          svgHeight: 600,
          svgScale: 1.3,
          person: person,
        ),
      ),
    );
  }
}
