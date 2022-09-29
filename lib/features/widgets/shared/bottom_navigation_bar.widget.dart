// A bottom navigation bar que tinha antes mas que não será visível para o administrador mas talvez possa ser usada no módulo do usuário. Foi movida para cá para liberar espaço no svg_map.view

import 'package:flutter/material.dart';

class BottomNavigationBarShared extends StatelessWidget {
  const BottomNavigationBarShared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      margin: const EdgeInsets.all(16),
      height: 80,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.deepOrange,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.arrow_upward_outlined,
            size: 40,
            color: Colors.white,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.social_distance,
                color: Colors.white,
              ),
              Text("2 Km"),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.timelapse,
                color: Colors.white,
              ),
              Text("1 min"),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.timer,
                color: Colors.white,
              ),
              Text("10:56"),
            ],
          ),
        ],
      ),
    );
  }
}
