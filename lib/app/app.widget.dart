import 'package:flutter/material.dart';
import 'package:mvp_proex/features/login/login.view.dart';
import 'package:mvp_proex/features/map/map.view.dart';
import 'package:mvp_proex/features/user/user.model.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => UserModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MVP Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: '/map',
        routes: {
          '/map': (context) => const MapView(),
          '/login': (context) => const LoginView(),
        },
      ),
    );
  }
}
